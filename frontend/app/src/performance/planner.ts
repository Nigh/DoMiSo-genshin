import type { GameInstrumentProfile, StateTransition } from "../game-mapping"

export type NativeKeyAction = { atMs: number; scanCode: number; down: boolean }

type Note = { tick: number; duration: number; noteNumber: number }
type Tempo = { tick: number; microsecondsPerBeat: number }

function transitionsBetween(
  profile: GameInstrumentProfile,
  from: string,
  to: string,
): StateTransition[] | undefined {
  if (from === to) return []
  const queue: { state: string; path: StateTransition[] }[] = [{ state: from, path: [] }]
  const seen = new Set([from])
  while (queue.length) {
    const current = queue.shift()!
    for (const transition of profile.transitions.filter((item) => item.from === current.state)) {
      if (seen.has(transition.to)) continue
      const path = [...current.path, transition]
      if (transition.to === to) return path
      seen.add(transition.to)
      queue.push({ state: transition.to, path })
    }
  }
}

function millisAtTick(tick: number, timebase: number, tempos: Tempo[]) {
  let previousTick = 0
  let microsecondsPerBeat = 500_000
  let milliseconds = 0
  for (const tempo of tempos) {
    if (tempo.tick > tick) break
    milliseconds += ((tempo.tick - previousTick) / timebase) * microsecondsPerBeat / 1000
    previousTick = tempo.tick
    microsecondsPerBeat = tempo.microsecondsPerBeat
  }
  return milliseconds + ((tick - previousTick) / timebase) * microsecondsPerBeat / 1000
}

export function buildKeySequence(
  song: { timebase: number; tracks: readonly any[] },
  profile: GameInstrumentProfile,
  startTick: number,
  shouldPlayTrack: (track: any) => boolean = () => true,
): NativeKeyAction[] {
  const tempos = song.tracks.flatMap((track) => track.events)
    .filter((event) => event.subtype === "setTempo") as Tempo[]
  tempos.sort((a, b) => a.tick - b.tick)
  const notes = song.tracks.filter((track) => !track.isConductorTrack && shouldPlayTrack(track))
    .flatMap((track) => track.events)
    .filter((event) => event.subtype === "note" && event.tick >= startTick) as Note[]
  notes.sort((a, b) => a.tick - b.tick)

  const byTick = new Map<number, Note[]>()
  for (const note of notes) byTick.set(note.tick, [...(byTick.get(note.tick) ?? []), note])
  const origin = millisAtTick(startTick, song.timebase, tempos)
  const actions: NativeKeyAction[] = []
  let state = profile.initialState

  for (const [tick, chord] of byTick) {
    const targetState = [
      profile.states.find((candidate) => candidate.id === state),
      ...profile.states.filter((candidate) => candidate.id !== state),
    ].find((candidate) => candidate && chord.every((note) => Object.values(candidate.bindings).includes(note.noteNumber)))
    if (!targetState) throw new Error(`无法映射 tick ${tick} 的和弦`)

    let atMs = Math.round(millisAtTick(tick, song.timebase, tempos) - origin)
    const transitions = transitionsBetween(profile, state, targetState.id)
    if (!transitions) throw new Error(`无法从状态 ${state} 切换到 ${targetState.id}`)
    for (const transition of transitions) {
      actions.push({ atMs, scanCode: transition.scanCode, down: true })
      actions.push({ atMs: atMs + profile.timing.keyDownMs, scanCode: transition.scanCode, down: false })
      atMs += profile.timing.stateSwitchDelayMs
    }
    state = targetState.id

    for (const note of chord) {
      const keyCode = Object.entries(targetState.bindings).find(([, value]) => value === note.noteNumber)![0]
      const scanCode = profile.scanCodes[keyCode]
      actions.push({ atMs, scanCode, down: true })
      const naturalEnd = Math.round(millisAtTick(note.tick + note.duration, song.timebase, tempos) - origin)
      actions.push({ atMs: Math.max(atMs + profile.timing.keyDownMs, naturalEnd), scanCode, down: false })
    }
  }
  return actions.sort((a, b) => a.atMs - b.atMs || Number(a.down) - Number(b.down))
}
