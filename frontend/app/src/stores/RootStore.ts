import { CommandService } from "@signal-app/core"
import { Player, SoundFont, SoundFontSynth } from "@signal-app/player"
import { EventSource } from "../player/EventSource"
import { AutoSaveService } from "../services/AutoSaveService"
import { GroupOutput } from "../services/GroupOutput"
import { MIDIActivity } from "../services/MIDIActivity"
import { MIDIInput } from "../services/MIDIInput"
import { MIDIMonitor } from "../services/MIDIMonitor"
import { MIDIRecorder } from "../services/MIDIRecorder"
import { BluetoothMIDIDeviceStore } from "./BluetoothMIDIDeviceStore"
import { MIDIDeviceStore } from "./MIDIDeviceStore"
import { registerReactions } from "./reactions"
import { SongStore } from "./SongStore"
import { SoundFontStore } from "./SoundFontStore"

export default class RootStore {
  readonly songStore = new SongStore()
  readonly midiDeviceStore: MIDIDeviceStore
  readonly player: Player
  readonly synth: SoundFontSynth
  readonly metronomeSynth: SoundFontSynth
  readonly synthGroup: GroupOutput
  readonly midiInput = new MIDIInput()
  readonly midiRecorder: MIDIRecorder
  readonly midiMonitor: MIDIMonitor
  readonly midiActivity: MIDIActivity
  readonly soundFontStore: SoundFontStore
  readonly bluetoothMIDIDeviceStore: BluetoothMIDIDeviceStore
  readonly autoSaveService: AutoSaveService
  readonly commands = new CommandService(this.songStore)

  constructor() {
    const context = new (window.AudioContext || window.webkitAudioContext)()
    this.synth = new SoundFontSynth(context)
    this.metronomeSynth = new SoundFontSynth(context)
    this.synthGroup = new GroupOutput(this.metronomeSynth)
    this.synthGroup.outputs.push({ synth: this.synth, isEnabled: true })

    const eventSource = new EventSource(this.songStore)
    this.player = new Player(this.synthGroup, eventSource)

    this.soundFontStore = new SoundFontStore(this.synth)

    this.midiDeviceStore = new MIDIDeviceStore(this.midiInput)
    this.bluetoothMIDIDeviceStore = new BluetoothMIDIDeviceStore(this.midiInput)
    this.midiRecorder = new MIDIRecorder(
      this.songStore,
      this.player,
      this.midiDeviceStore,
    )
    this.midiMonitor = new MIDIMonitor(this.player, this.midiDeviceStore)
    this.midiActivity = new MIDIActivity(
      this.midiDeviceStore,
      this.midiRecorder,
      this.songStore,
    )

    this.midiInput.on("midiMessage", (e) => {
      this.midiActivity.onMessage(e)
      this.midiMonitor.onMessage(e)
      this.midiRecorder.onMessage(e)
    })

    this.autoSaveService = new AutoSaveService(this.songStore)

    registerReactions(this)
  }

  async init() {
    await this.synth.setup()
    await this.soundFontStore.init().catch(console.warn)
    this.setupMetronomeSynth().catch(console.warn)
    this.autoSaveService.startAutoSave()
    this.bluetoothMIDIDeviceStore.autoConnect()
  }

  private async setupMetronomeSynth() {
    const data = await loadMetronomeSoundFontData()
    await this.metronomeSynth.loadSoundFont(await SoundFont.load(data))
  }
}

async function loadMetronomeSoundFontData() {
  const soundFontURL = "./soundfonts/GeneralUser-GS.sf2"
  const response = await fetch(soundFontURL)
  const data = await response.arrayBuffer()
  return data
}
