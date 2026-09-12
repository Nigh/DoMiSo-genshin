export function tickToMillisec(tick: number, bpm: number, timebase: number) {
  return (tick / (timebase / 60) / bpm) * 1000
}
