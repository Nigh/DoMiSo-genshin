import { MIDIControlEventNames } from "midifile-ts"

const NOTE_NAMES = [
  "C",
  "C#",
  "D",
  "D#",
  "E",
  "F",
  "F#",
  "G",
  "G#",
  "A",
  "A#",
  "B",
]

function noteNameWithOctString(noteNumber: number): string {
  const oct = Math.floor(noteNumber / 12) - 1
  const key = noteNumber % 12
  return `${NOTE_NAMES[key]}${oct}`
}

function noteNumberString(noteNumber: number): string {
  return `${noteNameWithOctString(noteNumber)} (${noteNumber})`
}

function controllerTypeString(controllerType: number): string {
  return MIDIControlEventNames[controllerType]
}

export { noteNameWithOctString, noteNumberString, controllerTypeString }
