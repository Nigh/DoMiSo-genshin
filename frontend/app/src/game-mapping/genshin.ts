import type { GameInstrumentProfile } from "./types"

const rows = [
  ["KeyZ", "KeyX", "KeyC", "KeyV", "KeyB", "KeyN", "KeyM"],
  ["KeyA", "KeyS", "KeyD", "KeyF", "KeyG", "KeyH", "KeyJ"],
  ["KeyQ", "KeyW", "KeyE", "KeyR", "KeyT", "KeyY", "KeyU"],
]
const whiteKeys = [0, 2, 4, 5, 7, 9, 11]
const scanCodes: Record<string, number> = {
  KeyA: 0x1e, KeyB: 0x30, KeyC: 0x2e, KeyD: 0x20, KeyE: 0x12,
  KeyF: 0x21, KeyG: 0x22, KeyH: 0x23, KeyJ: 0x24, KeyM: 0x32,
  KeyN: 0x31, KeyQ: 0x10, KeyR: 0x13, KeyS: 0x1f, KeyT: 0x14,
  KeyU: 0x16, KeyV: 0x2f, KeyW: 0x11, KeyX: 0x2d, KeyY: 0x15,
  KeyZ: 0x2c,
}

export const genshinWindsongLyre: GameInstrumentProfile = {
  version: 1,
  id: "genshin-windsong-lyre",
  name: "原神风物之诗琴",
  processNames: ["YuanShen.exe", "GenshinImpact.exe"],
  initialState: "default",
  states: [
    {
      id: "default",
      label: "默认",
      bindings: Object.fromEntries(
        rows.flatMap((row, octave) =>
          row.map((key, degree) => [key, 48 + octave * 12 + whiteKeys[degree]]),
        ),
      ),
    },
  ],
  transitions: [],
  scanCodes,
  timing: { keyDownMs: 35, chordGapMs: 8, stateSwitchDelayMs: 80 },
}
