import { useCallback } from "react"
import { BLEMIDI } from "web-ble-midi"
import { useMobxGetter } from "./useMobxSelector"
import { useStores } from "./useStores"

export interface Device {
  id: string
  name: string
  isConnected: boolean
  isEnabled: boolean
  isBluetooth?: boolean
}

export function useMIDIDevice() {
  const { midiDeviceStore, bluetoothMIDIDeviceStore } = useStores()

  const inputs = useMobxGetter(midiDeviceStore, "inputs")
  const outputs = useMobxGetter(midiDeviceStore, "outputs")
  const btInputs = useMobxGetter(bluetoothMIDIDeviceStore, "inputs")
  const btEnabledInputs = useMobxGetter(
    bluetoothMIDIDeviceStore,
    "enabledInputs",
  )

  const enabledInputs = useMobxGetter(midiDeviceStore, "enabledInputs")
  const enabledOutputs = useMobxGetter(midiDeviceStore, "enabledOutputs")

  const isFactorySoundEnabled = useMobxGetter(
    midiDeviceStore,
    "isFactorySoundEnabled",
  )

  // 通常MIDI + Bluetooth MIDI
  const inputDevices: Device[] = [
    ...inputs.map((device) => ({
      id: device.id,
      name: formatName(device),
      isConnected: device.state === "connected",
      isEnabled: enabledInputs[device.id],
      isBluetooth: false,
    })),
    ...btInputs.map((d) => ({
      id: d.id,
      name: d.name ?? "Bluetooth MIDI Device",
      isConnected: btInputs.some((i) => i.id === d.id),
      isEnabled: btEnabledInputs[d.id],
      isBluetooth: true,
    })),
  ]

  const outputDevices: Device[] = [
    {
      ...factorySound,
      isEnabled: isFactorySoundEnabled,
    },
    ...outputs.map((device) => ({
      id: device.id,
      name: formatName(device),
      isConnected: device.state === "connected",
      isEnabled: enabledOutputs[device.id],
      isBluetooth: false,
    })),
  ]

  return {
    inputDevices,
    outputDevices,
    get isLoading() {
      return (
        useMobxGetter(midiDeviceStore, "isLoading") ||
        useMobxGetter(bluetoothMIDIDeviceStore, "isLoading")
      )
    },
    get requestError() {
      return (
        useMobxGetter(midiDeviceStore, "requestError") ||
        useMobxGetter(bluetoothMIDIDeviceStore, "requestError")
      )
    },
    get midiInputRouting() {
      return useMobxGetter(midiDeviceStore, "midiInputRouting")
    },
    isBluetoothSupported: BLEMIDI.isSupported(),
    requestMIDIAccess: midiDeviceStore.requestMIDIAccess,
    requestBluetoothMIDIDevice: useCallback(() => {
      bluetoothMIDIDeviceStore.requestDevice()
    }, [bluetoothMIDIDeviceStore]),
    setInputEnable: useCallback(
      (deviceId: string, isEnabled: boolean) => {
        if (btInputs.some((d) => d.id === deviceId)) {
          bluetoothMIDIDeviceStore.setInputEnable(deviceId, isEnabled)
        } else {
          midiDeviceStore.setInputEnable(deviceId, isEnabled)
        }
      },
      [midiDeviceStore, bluetoothMIDIDeviceStore, btInputs],
    ),
    setMidiInputRouting: midiDeviceStore.setMidiInputRouting,
    setOutputEnable: useCallback(
      (deviceId: string, isEnabled: boolean) => {
        if (deviceId === factorySound.id) {
          midiDeviceStore.isFactorySoundEnabled = isEnabled
        } else {
          midiDeviceStore.setOutputEnable(deviceId, isEnabled)
        }
      },
      [midiDeviceStore],
    ),
  }
}

const formatName = (device: WebMidi.MIDIPort) =>
  (device?.name ?? "") +
  ((device.manufacturer?.length ?? 0) > 0 ? `(${device.manufacturer})` : "")

const factorySound = {
  id: "signal-midi-app",
  name: "Signal Factory Sound",
  isConnected: true,
}

export const useCanRecord = () => {
  const { midiDeviceStore } = useStores()
  const enabledInputs = useMobxGetter(midiDeviceStore, "enabledInputs")

  return Object.values(enabledInputs).filter((e) => e).length > 0
}
