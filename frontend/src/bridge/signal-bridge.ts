export type SignalStatus = "loading" | "ready" | "playing" | "error"

export interface PlayerState {
  isPlaying: boolean
  position: number
  endOfSong: number
  tempo: number
  mbtTime: string
}

export interface SongMeta {
  endOfSong: number
  timebase: number
  trackCount: number
}

export interface SignalBridge {
  loadMIDI: (midiBytes: Uint8Array) => void
  onReady: (callback: () => void) => void
  onMIDILoaded: (callback: (success: boolean, error?: string) => void) => void
  dispose: () => void
  play: () => void
  stop: () => void
  seek: (tick: number) => void
  rewind: () => void
  fastForward: () => void
  requestState: () => void
  onStateUpdate: (callback: (state: PlayerState) => void) => void
  onSongLoaded: (callback: (meta: SongMeta) => void) => void
}

export function createSignalBridge(iframe: HTMLIFrameElement): SignalBridge {
  let readyCallback: (() => void) | null = null
  let loadedCallback: ((success: boolean, error?: string) => void) | null = null
  let stateUpdateCallback: ((state: PlayerState) => void) | null = null
  let songLoadedCallback: ((meta: SongMeta) => void) | null = null

  const handler = (event: MessageEvent) => {
    switch (event.data?.type) {
      case "SIGNAL_READY":
        readyCallback?.()
        break
      case "MIDI_LOADED":
        loadedCallback?.(event.data.success, event.data.error)
        break
      case "STATE_UPDATE":
        stateUpdateCallback?.(event.data.data)
        break
      case "SONG_LOADED":
        songLoadedCallback?.(event.data.data)
        break
    }
  }

  window.addEventListener("message", handler)

  function postToSignal(type: string, data?: unknown) {
    if (!iframe.contentWindow) return
    iframe.contentWindow.postMessage(
      data !== undefined ? { type, data } : { type },
      "*",
    )
  }

  return {
    loadMIDI(midiBytes: Uint8Array) {
      if (!iframe.contentWindow) {
        loadedCallback?.(false, "Signal iframe not available")
        return
      }
      postToSignal("LOAD_MIDI", Array.from(midiBytes))
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
      stateUpdateCallback = null
      songLoadedCallback = null
    },
    play() {
      postToSignal("PLAY")
    },
    stop() {
      postToSignal("STOP")
    },
    seek(tick: number) {
      postToSignal("SEEK", { tick })
    },
    rewind() {
      postToSignal("REWIND")
    },
    fastForward() {
      postToSignal("FAST_FORWARD")
    },
    requestState() {
      postToSignal("GET_STATE")
    },
    onStateUpdate(callback: (state: PlayerState) => void) {
      stateUpdateCallback = callback
    },
    onSongLoaded(callback: (meta: SongMeta) => void) {
      songLoadedCallback = callback
    },
  }
}
