import { describe, expect, it } from "vitest"
import { matchesFreshChord } from "./judgement"

describe("practice chord judgement", () => {
  it("requires an exact chord with a fresh press", () => {
    expect(matchesFreshChord([60, 64], new Set([60, 64]), new Set([64]))).toBe(true)
    expect(matchesFreshChord([60, 64], new Set([60]), new Set([60]))).toBe(false)
    expect(matchesFreshChord([60, 64], new Set([60, 64, 67]), new Set([67]))).toBe(false)
    expect(matchesFreshChord([60, 64], new Set([60, 64]), new Set())).toBe(false)
  })
})
