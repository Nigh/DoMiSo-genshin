export type MappingState = {
  id: string
  label: string
  bindings: Record<string, number>
}

export type StateTransition = {
  from: string
  to: string
  keyCode: string
  scanCode: number
}

export type GameInstrumentProfile = {
  version: 1
  id: string
  name: string
  processNames: string[]
  initialState: string
  states: MappingState[]
  transitions: StateTransition[]
  scanCodes: Record<string, number>
  timing: {
    keyDownMs: number
    chordGapMs: number
    stateSwitchDelayMs: number
  }
}

export type KeyMappingResult =
  | { type: "note"; noteNumber: number }
  | { type: "stateChange"; state: string }
  | { type: "unmapped" }

export type PitchMappingResult =
  | { type: "key"; keyCode: string; scanCode: number; state: string }
  | { type: "unmapped" }
