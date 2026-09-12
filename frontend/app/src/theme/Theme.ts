export interface Theme {
  isLightContent: boolean // if true, text color is light and background color is dark
  font: string
  monoFont: string
  canvasFont: string
  themeColor: string
  onSurfaceColor: string // content color on themeColor
  darkBackgroundColor: string
  backgroundColor: string
  secondaryBackgroundColor: string
  editorBackgroundColor: string // control pane / arrange view / tempo editor
  editorGridColor: string
  editorSecondaryGridColor: string
  dividerColor: string
  popupBorderColor: string
  textColor: string
  secondaryTextColor: string
  tertiaryTextColor: string
  pianoKeyBlack: string
  pianoKeyWhite: string
  pianoWhiteKeyLaneColor: string
  pianoBlackKeyLaneColor: string
  pianoHighlightedLaneColor: string
  pianoLaneEdgeColor: string
  ghostNoteColor: string
  recordColor: string
  shadowColor: string
  highlightColor: string
  greenColor: string
  redColor: string
  yellowColor: string
}

const darkTheme: Theme = {
  isLightContent: true,
  font: 'Inter, "Noto Sans SC", ui-sans-serif, system-ui, sans-serif',
  monoFont: '"JetBrains Mono", "Fira Code", ui-monospace, "Cascadia Code", monospace',
  canvasFont: "Arial",
  themeColor: "#ffa1ad",
  onSurfaceColor: "#242424",
  textColor: "#f2f2f2",
  secondaryTextColor: "#b7b7b8",
  tertiaryTextColor: "#868687",
  dividerColor: "#404040",
  popupBorderColor: "#404040",
  darkBackgroundColor: "#161616",
  backgroundColor: "#242424",
  secondaryBackgroundColor: "#404040",
  editorBackgroundColor: "#161616",
  editorSecondaryGridColor: "#2e2e2e",
  editorGridColor: "#404040",
  pianoKeyBlack: "#272a36",
  pianoKeyWhite: "#fbfcff",
  pianoWhiteKeyLaneColor: "hsl(228, 10%, 16%)",
  pianoBlackKeyLaneColor: "hsl(228, 10%, 13%)",
  pianoHighlightedLaneColor: "hsl(230, 23%, 20%)",
  pianoLaneEdgeColor: "hsl(228, 10%, 18%)",
  ghostNoteColor: "#444444",
  recordColor: "#dd3c3c",
  shadowColor: "rgba(0, 0, 0, 0.1)",
  highlightColor: "rgba(64, 64, 64, 0.55)",
  greenColor: "#7fc08c",
  redColor: "#fa6863",
  yellowColor: "#eebc4a",
}

const lightTheme: Theme = {
  isLightContent: false,
  font: 'Inter, "Noto Sans SC", ui-sans-serif, system-ui, sans-serif',
  monoFont: '"JetBrains Mono", "Fira Code", ui-monospace, "Cascadia Code", monospace',
  canvasFont: "Arial",
  themeColor: "#b3485c",
  onSurfaceColor: "#f8f8f8",
  textColor: "#161616",
  secondaryTextColor: "#4d4d4d",
  tertiaryTextColor: "#7a7a7b",
  dividerColor: "#d4d4d4",
  popupBorderColor: "#d4d4d4",
  darkBackgroundColor: "#e8e8e8",
  backgroundColor: "#f5f5f5",
  secondaryBackgroundColor: "#e8e8e8",
  editorBackgroundColor: "#f5f5f5",
  editorGridColor: "#d4d4d4",
  editorSecondaryGridColor: "#e8e8e8",
  pianoKeyBlack: "#272a36",
  pianoKeyWhite: "#fbfcff",
  pianoWhiteKeyLaneColor: "#ffffff",
  pianoBlackKeyLaneColor: "hsl(228, 10%, 96%)",
  pianoHighlightedLaneColor: "hsl(228, 70%, 97%)",
  pianoLaneEdgeColor: "hsl(228, 10%, 92%)",
  ghostNoteColor: "hsl(223, 12%, 80%)",
  recordColor: "#ee6a6a",
  shadowColor: "rgba(0, 0, 0, 0.1)",
  highlightColor: "rgba(212, 212, 212, 0.55)",
  greenColor: "#337344",
  redColor: "#b71824",
  yellowColor: "#a07100",
}

export const themes = {
  dark: darkTheme,
  light: lightTheme,
} as const

export const themeNames = Object.keys(themes) as (keyof typeof themes)[]
export type ThemeType = (typeof themeNames)[number]
