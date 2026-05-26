export type SignalStatus = "loading" | "ready" | "playing" | "error"

export interface SignalBridge {
  loadMIDI: (midiBytes: Uint8Array) => void
  onReady: (callback: () => void) => void
  onMIDILoaded: (callback: (success: boolean, error?: string) => void) => void
  dispose: () => void
}

export function createSignalBridge(iframe: HTMLIFrameElement): SignalBridge {
  let readyCallback: (() => void) | null = null
  let loadedCallback: ((success: boolean, error?: string) => void) | null = null

  const handler = (event: MessageEvent) => {
    switch (event.data?.type) {
      case "SIGNAL_READY":
        readyCallback?.()
        break
      case "MIDI_LOADED":
        loadedCallback?.(event.data.success, event.data.error)
        break
    }
  }

  window.addEventListener("message", handler)

  return {
    loadMIDI(midiBytes: Uint8Array) {
      if (!iframe.contentWindow) {
        loadedCallback?.(false, "Signal iframe not available")
        return
      }
      iframe.contentWindow.postMessage(
        {
          type: "LOAD_MIDI",
          data: Array.from(midiBytes),
        },
        "*",
      )
    },
    onReady(callback: () => void) {
      readyCallback = callback
    },
    onMIDILoaded(callback: (success: boolean, error?: string) => void) {
      loadedCallback = callback
    },
    dispose() {
      window.removeEventListener("message", handler)
      readyCallback = null
      loadedCallback = null
    },
  }
}
