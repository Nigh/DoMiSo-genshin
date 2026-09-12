export function matchesFreshChord(
  target: readonly number[],
  pressed: ReadonlySet<number>,
  pressedSinceTarget: ReadonlySet<number>,
) {
  const expected = new Set(target)
  return pressed.size === expected.size &&
    [...expected].every((note) => pressed.has(note)) &&
    [...expected].some((note) => pressedSinceTarget.has(note))
}
