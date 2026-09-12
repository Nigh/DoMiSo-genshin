import type {
  GameInstrumentProfile,
  KeyMappingResult,
  PitchMappingResult,
} from "./types"

export function keyToPitch(
  profile: GameInstrumentProfile,
  state: string,
  keyCode: string,
): KeyMappingResult {
  const transition = profile.transitions.find(
    (item) => item.from === state && item.keyCode === keyCode,
  )
  if (transition) return { type: "stateChange", state: transition.to }

  const noteNumber = profile.states.find((item) => item.id === state)?.bindings[
    keyCode
  ]
  return noteNumber === undefined
    ? { type: "unmapped" }
    : { type: "note", noteNumber }
}

export function pitchToKey(
  profile: GameInstrumentProfile,
  state: string,
  noteNumber: number,
): PitchMappingResult {
  const states = [
    ...profile.states.filter((item) => item.id === state),
    ...profile.states.filter((item) => item.id !== state),
  ]
  for (const candidate of states) {
    const entry = Object.entries(candidate.bindings).find(
      ([, note]) => note === noteNumber,
    )
    if (entry) {
      return {
        type: "key",
        keyCode: entry[0],
        scanCode: profile.scanCodes[entry[0]],
        state: candidate.id,
      }
    }
  }
  return { type: "unmapped" }
}
