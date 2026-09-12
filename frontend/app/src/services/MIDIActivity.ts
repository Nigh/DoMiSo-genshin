import { TrackId, UNASSIGNED_TRACK_ID } from "@signal-app/core"
import { MIDIDeviceStore } from "../stores/MIDIDeviceStore"
import { SongStore } from "../stores/SongStore"
import { MIDIInputEvent } from "./MIDIInput"
import { MIDIRecorder } from "./MIDIRecorder"

export class MIDIActivity {
  private readonly listeners = new Set<(trackIds: TrackId[]) => void>()

  constructor(
    private readonly midiDeviceStore: MIDIDeviceStore,
    private readonly midiRecorder: MIDIRecorder,
    private readonly songStore: SongStore,
  ) {}

  onActivity(callback: (trackIds: TrackId[]) => void): () => void {
    this.listeners.add(callback)
    return () => this.listeners.delete(callback)
  }

  onMessage(e: MIDIInputEvent): void {
    const trackIds = this.getRoutingTargetTrackIds(e)
    if (trackIds.length > 0) {
      this.listeners.forEach((cb) => cb(trackIds))
    }
  }

  private getRoutingTargetTrackIds(e: MIDIInputEvent): TrackId[] {
    if (e.data.length === 0) return []
    const statusByte = e.data[0]
    // Only handle channel messages (0x80–0xEF)
    if (statusByte < 0x80 || statusByte >= 0xf0) return []
    const msgType = (statusByte >> 4) & 0x0f
    // Ignore note-off (0x8n) and note-on with velocity 0 (0x9n, velocity=0)
    if (msgType === 0x8) return []
    if (msgType === 0x9 && e.data.length >= 3 && e.data[2] === 0) return []

    const routing = this.midiDeviceStore.midiInputRouting
    if (routing === "selectedTrack") {
      const trackId = this.midiRecorder.trackId
      return trackId !== UNASSIGNED_TRACK_ID ? [trackId] : []
    } else {
      const channel = statusByte & 0x0f
      return this.songStore.song.tracks
        .filter((t) => !t.isConductorTrack && t.channel === channel)
        .map((t) => t.id)
    }
  }
}
