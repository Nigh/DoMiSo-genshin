import React from "react"

interface ToolbarProps {
  onImport: () => void
  isLoading: boolean
  signalReady: boolean
  statusMessage: string
}

export function Toolbar({
  onImport,
  isLoading,
  signalReady,
  statusMessage,
}: ToolbarProps) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: "12px",
        padding: "8px 16px",
        backgroundColor: "#181825",
        borderBottom: "1px solid #313244",
      }}
    >
      <button
        onClick={onImport}
        disabled={isLoading || !signalReady}
        style={{
          padding: "6px 16px",
          border: "none",
          borderRadius: "4px",
          backgroundColor: isLoading || !signalReady ? "#45475a" : "#89b4fa",
          color: "#1e1e2e",
          fontWeight: 600,
          fontSize: "13px",
          cursor: isLoading || !signalReady ? "not-allowed" : "pointer",
          fontFamily: "inherit",
        }}
      >
        {isLoading ? "Parsing..." : "Import to Piano Roll"}
      </button>
      <span
        style={{
          fontSize: "12px",
          color: signalReady ? "#a6e3a1" : "#f9e2af",
          fontFamily: "inherit",
        }}
      >
        {statusMessage}
      </span>
    </div>
  )
}
