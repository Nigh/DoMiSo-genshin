import React from "react"

interface SheetEditorProps {
  value: string
  onChange: (value: string) => void
}

export function SheetEditor({ value, onChange }: SheetEditorProps) {
  return (
    <textarea
      style={{
        width: "100%",
        height: "100%",
        resize: "none",
        fontFamily: "'Roboto Mono', 'Consolas', monospace",
        fontSize: "14px",
        lineHeight: "1.6",
        padding: "16px",
        border: "none",
        outline: "none",
        backgroundColor: "#1e1e2e",
        color: "#cdd6f4",
        tabSize: 4,
      }}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder="Enter DoMiSo notation here..."
      spellCheck={false}
    />
  )
}
