import { describe, expect, it } from "vitest"
import { genshinWindsongLyre } from "./genshin"
import { keyToPitch, pitchToKey } from "./mapper"

describe("game instrument mapping", () => {
  it("round-trips every Genshin key", () => {
    const bindings = genshinWindsongLyre.states[0].bindings
    expect(Object.keys(bindings)).toHaveLength(21)
    for (const [keyCode, noteNumber] of Object.entries(bindings)) {
      expect(keyToPitch(genshinWindsongLyre, "default", keyCode)).toEqual({
        type: "note",
        noteNumber,
      })
      expect(pitchToKey(genshinWindsongLyre, "default", noteNumber)).toMatchObject({
        type: "key",
        keyCode,
        state: "default",
      })
    }
  })

  it("reports unmapped input", () => {
    expect(keyToPitch(genshinWindsongLyre, "default", "Space")).toEqual({
      type: "unmapped",
    })
    expect(pitchToKey(genshinWindsongLyre, "default", 1)).toEqual({
      type: "unmapped",
    })
  })
})
