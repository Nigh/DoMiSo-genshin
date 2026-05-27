import React from "react"

export interface SheetStats {
  noteCount: number
  measureCount: number
  durationSec: number
  bpm: number
  ticksPerBeat: number
}

interface StatusBarProps {
  stats: SheetStats | null
  format: string
}

function formatDuration(seconds: number): string {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, "0")}`
}

function formatMeasures(count: number): string {
  if (count < 0.01) return "0"
  if (count === Math.floor(count)) return count.toString()
  return count.toFixed(1)
}

export function StatusBar({ stats, format }: StatusBarProps) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: "16px",
        padding: "4px 12px",
        backgroundColor: "#181825",
        borderTop: "1px solid #313244",
        fontSize: "11px",
        color: "#a6adc8",
        fontFamily: "'Roboto Mono', monospace",
        flexShrink: 0,
        height: "24px",
      }}
    >
      {stats ? (
        <>
          <span>
            <span style={{ color: "#585b70" }}>Notes: </span>
            <span style={{ color: "#cdd6f4" }}>{stats.noteCount}</span>
          </span>
          <span>
            <span style={{ color: "#585b70" }}>Measures: </span>
            <span style={{ color: "#cdd6f4" }}>
              {formatMeasures(stats.measureCount)}
            </span>
          </span>
          <span>
            <span style={{ color: "#585b70" }}>Duration: </span>
            <span style={{ color: "#cdd6f4" }}>
              {formatDuration(stats.durationSec)}
            </span>
          </span>
          <span>
            <span style={{ color: "#585b70" }}>BPM: </span>
            <span style={{ color: "#cdd6f4" }}>{stats.bpm}</span>
          </span>
        </>
      ) : (
        <span style={{ color: "#585b70" }}>No sheet loaded</span>
      )}
      {format && (
        <span style={{ marginLeft: "auto" }}>
          <span style={{ color: "#585b70" }}>Format: </span>
          <span style={{ color: "#89b4fa" }}>{format.toUpperCase()}</span>
        </span>
      )}
    </div>
  )
}
