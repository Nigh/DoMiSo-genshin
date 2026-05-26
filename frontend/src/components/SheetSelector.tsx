import React from "react"

interface SheetInfo {
  name: string
  path: string
}

interface SheetSelectorProps {
  sheets: SheetInfo[]
  selectedSheet: string | null
  onSelect: (sheet: SheetInfo) => void
  onRefresh: () => void
  isLoading: boolean
}

export function SheetSelector({
  sheets,
  selectedSheet,
  onSelect,
  onRefresh,
  isLoading,
}: SheetSelectorProps) {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        gap: "2px",
        overflowY: "auto",
        flex: 1,
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          padding: "8px 12px",
          borderBottom: "1px solid #313244",
        }}
      >
        <span style={{ fontSize: "12px", color: "#a6adc8", fontWeight: 600 }}>
          Free Sheets
        </span>
        <button
          onClick={onRefresh}
          disabled={isLoading}
          style={{
            background: "none",
            border: "none",
            color: "#89b4fa",
            cursor: "pointer",
            fontSize: "12px",
            padding: "2px 6px",
          }}
        >
          {isLoading ? "..." : "Refresh"}
        </button>
      </div>
      {sheets.map((sheet) => (
        <button
          key={sheet.path}
          onClick={() => onSelect(sheet)}
          style={{
            display: "block",
            width: "100%",
            textAlign: "left",
            padding: "8px 12px",
            border: "none",
            cursor: "pointer",
            fontSize: "13px",
            fontFamily: "inherit",
            backgroundColor:
              selectedSheet === sheet.path ? "#313244" : "transparent",
            color: selectedSheet === sheet.path ? "#cdd6f4" : "#a6adc8",
            whiteSpace: "nowrap",
            overflow: "hidden",
            textOverflow: "ellipsis",
          }}
          onMouseEnter={(e) => {
            if (selectedSheet !== sheet.path) {
              e.currentTarget.style.backgroundColor = "#181825"
            }
          }}
          onMouseLeave={(e) => {
            if (selectedSheet !== sheet.path) {
              e.currentTarget.style.backgroundColor = "transparent"
            }
          }}
        >
          {sheet.name}
        </button>
      ))}
    </div>
  )
}
