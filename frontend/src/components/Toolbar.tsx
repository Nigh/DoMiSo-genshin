import React, { useCallback, useRef } from "react"
import type { PlayerState } from "../bridge/signal-bridge"

export type AppMode = "piano-roll" | "editor"

interface ToolbarProps {
  onSync: () => void
  isLoading: boolean
  signalReady: boolean
  statusMessage: string
  mode: AppMode
  onModeChange: (mode: AppMode) => void
  playerState: PlayerState | null
  songLoaded: boolean
  onPlay: () => void
  onStop: () => void
  onSeek: (tick: number) => void
  onImportFile: () => void
  onExportFile: () => void
}

export function Toolbar({
  onSync,
  isLoading,
  signalReady,
  statusMessage,
  mode,
  onModeChange,
  playerState,
  songLoaded,
  onPlay,
  onStop,
  onSeek,
  onImportFile,
  onExportFile,
}: ToolbarProps) {
  const isPlaying = playerState?.isPlaying ?? false
  const position = playerState?.position ?? 0
  const endOfSong = playerState?.endOfSong ?? 0
  const mbtTime = playerState?.mbtTime ?? "1:1:0"
  const progressRef = useRef<HTMLInputElement>(null)
  const seekingRef = useRef(false)

  const progressPercent = endOfSong > 0 ? (position / endOfSong) * 100 : 0

  const handleProgressChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const percent = Number(e.target.value)
      if (endOfSong > 0) {
        const tick = Math.floor((percent / 100) * endOfSong)
        onSeek(tick)
      }
    },
    [endOfSong, onSeek],
  )

  const handleMouseDown = useCallback(() => {
    seekingRef.current = true
  }, [])

  const handleMouseUp = useCallback(() => {
    seekingRef.current = false
  }, [])

  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: "12px",
        padding: "8px 16px",
        backgroundColor: "#181825",
        borderBottom: "1px solid #313244",
        flexShrink: 0,
      }}
    >
      <div
        style={{
          display: "flex",
          borderRadius: "4px",
          overflow: "hidden",
          border: "1px solid #313244",
        }}
      >
        <button
          onClick={() => onModeChange("editor")}
          style={{
            padding: "5px 12px",
            border: "none",
            backgroundColor: mode === "editor" ? "#89b4fa" : "#1e1e2e",
            color: mode === "editor" ? "#1e1e2e" : "#a6adc8",
            fontSize: "12px",
            fontWeight: 600,
            cursor: "pointer",
            fontFamily: "inherit",
          }}
        >
          Editor
        </button>
        <button
          onClick={() => onModeChange("piano-roll")}
          style={{
            padding: "5px 12px",
            border: "none",
            backgroundColor: mode === "piano-roll" ? "#89b4fa" : "#1e1e2e",
            color: mode === "piano-roll" ? "#1e1e2e" : "#a6adc8",
            fontSize: "12px",
            fontWeight: 600,
            cursor: "pointer",
            fontFamily: "inherit",
          }}
        >
          Piano
        </button>
      </div>

      <div style={{ width: "1px", height: "20px", backgroundColor: "#313244" }} />

      <button
        onClick={onImportFile}
        style={{
          padding: "5px 12px",
          border: "1px solid #313244",
          borderRadius: "4px",
          backgroundColor: "#1e1e2e",
          color: "#a6adc8",
          fontSize: "12px",
          fontWeight: 600,
          cursor: "pointer",
          fontFamily: "inherit",
        }}
      >
        Open
      </button>
      <button
        onClick={onExportFile}
        style={{
          padding: "5px 12px",
          border: "1px solid #313244",
          borderRadius: "4px",
          backgroundColor: "#1e1e2e",
          color: "#a6adc8",
          fontSize: "12px",
          fontWeight: 600,
          cursor: "pointer",
          fontFamily: "inherit",
        }}
      >
        Save
      </button>

      <div style={{ width: "1px", height: "20px", backgroundColor: "#313244" }} />

      <button
        onClick={onSync}
        disabled={isLoading || !signalReady}
        style={{
          padding: "5px 14px",
          border: "none",
          borderRadius: "4px",
          backgroundColor: isLoading || !signalReady ? "#45475a" : "#89b4fa",
          color: "#1e1e2e",
          fontWeight: 600,
          fontSize: "12px",
          cursor: isLoading || !signalReady ? "not-allowed" : "pointer",
          fontFamily: "inherit",
        }}
      >
        {isLoading ? "Parsing..." : "Sync to Piano"}
      </button>

      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: "6px",
          opacity: songLoaded ? 1 : 0.4,
          pointerEvents: songLoaded ? "auto" : "none",
        }}
      >
        <button
          onClick={onPlay}
          style={{
            width: "28px",
            height: "28px",
            border: "none",
            borderRadius: "4px",
            backgroundColor: isPlaying ? "#f38ba8" : "#a6e3a1",
            color: "#1e1e2e",
            fontSize: "14px",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontFamily: "inherit",
            fontWeight: 700,
          }}
          title={isPlaying ? "Pause" : "Play"}
        >
          {isPlaying ? "\u275A\u275A" : "\u25B6"}
        </button>
        <button
          onClick={onStop}
          style={{
            width: "28px",
            height: "28px",
            border: "none",
            borderRadius: "4px",
            backgroundColor: "#45475a",
            color: "#cdd6f4",
            fontSize: "12px",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontFamily: "inherit",
            fontWeight: 700,
          }}
          title="Stop"
        >
          {"\u25A0"}
        </button>
      </div>

      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: "8px",
          flex: 1,
          minWidth: 0,
          opacity: songLoaded ? 1 : 0.4,
        }}
      >
        <input
          ref={progressRef}
          type="range"
          min={0}
          max={100}
          step={0.1}
          value={progressPercent}
          onChange={handleProgressChange}
          onMouseDown={handleMouseDown}
          onMouseUp={handleMouseUp}
          onTouchStart={handleMouseDown}
          onTouchEnd={handleMouseUp}
          disabled={!songLoaded}
          style={{
            flex: 1,
            height: "4px",
            accentColor: "#89b4fa",
            cursor: songLoaded ? "pointer" : "default",
          }}
        />
        <span
          style={{
            fontSize: "11px",
            color: "#a6adc8",
            fontFamily: "'Roboto Mono', monospace",
            whiteSpace: "nowrap",
            minWidth: "80px",
            textAlign: "right",
          }}
        >
          {mbtTime}
        </span>
      </div>

      <span
        style={{
          fontSize: "12px",
          color: signalReady ? "#a6e3a1" : "#f9e2af",
          fontFamily: "inherit",
          whiteSpace: "nowrap",
        }}
      >
        {statusMessage}
      </span>
    </div>
  )
}
