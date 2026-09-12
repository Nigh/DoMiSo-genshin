import { describe, expect, it } from "vitest"
import { genshinWindsongLyre } from "../game-mapping"
import { buildKeySequence } from "./planner"

describe("performance planner", () => {
  it("converts MIDI timing to balanced key actions", () => {
    const song = {
      timebase: 480,
      tracks: [{ isConductorTrack: false, events: [{ subtype: "note", tick: 480, duration: 480, noteNumber: 48 }] }],
    }
    expect(buildKeySequence(song, genshinWindsongLyre, 0)).toEqual([
      { atMs: 500, scanCode: 0x2c, down: true },
      { atMs: 1000, scanCode: 0x2c, down: false },
    ])
  })

  it("rejects unplayable chords before starting", () => {
    const song = { timebase: 480, tracks: [{ isConductorTrack: false, events: [{ subtype: "note", tick: 0, duration: 1, noteNumber: 1 }] }] }
    expect(() => buildKeySequence(song, genshinWindsongLyre, 0)).toThrow("tick 0")
  })
})
