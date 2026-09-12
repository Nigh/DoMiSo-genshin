import Color from "color"
import { describe, expect, it } from "vitest"
import { themes } from "./Theme"

describe("themes", () => {
  it("uses colors supported by Signal's runtime parser", () => {
    for (const theme of Object.values(themes)) {
      for (const [name, value] of Object.entries(theme)) {
        if (name.endsWith("Color")) expect(() => Color(value as string)).not.toThrow()
      }
    }
  })
})
