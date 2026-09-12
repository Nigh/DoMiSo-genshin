import React from "react"

export interface SheetMeta {
  title: string
  composer: string
  arranger: string
  description: string
  tempo: string
  timeSig: string
  key: string
}

interface MetaEditorProps {
  meta: SheetMeta
  onChange: (meta: SheetMeta) => void
}

const inputStyle: React.CSSProperties = {
  width: "100%",
  padding: "4px 8px",
  border: "1px solid #313244",
  borderRadius: "3px",
  backgroundColor: "#181825",
  color: "#cdd6f4",
  fontSize: "12px",
  fontFamily: "inherit",
  outline: "none",
}

const labelStyle: React.CSSProperties = {
  fontSize: "11px",
  color: "#a6adc8",
  marginBottom: "2px",
  display: "block",
}

const fieldStyle: React.CSSProperties = {
  display: "flex",
  flexDirection: "column",
  gap: "2px",
}

const fields: { key: keyof SheetMeta; label: string; placeholder: string }[] =
  [
    { key: "title", label: "Title", placeholder: "Sheet title" },
    { key: "composer", label: "Composer", placeholder: "Composer / Noter" },
    { key: "arranger", label: "Arranger", placeholder: "Arranger" },
    { key: "tempo", label: "Tempo", placeholder: "e.g. 120" },
    { key: "timeSig", label: "Time Sig", placeholder: "e.g. 4/4" },
    { key: "key", label: "Key", placeholder: "e.g. C" },
    {
      key: "description",
      label: "Description",
      placeholder: "Description or notes",
    },
  ]

export function MetaEditor({ meta, onChange }: MetaEditorProps) {
  const update = (key: keyof SheetMeta, val: string) => {
    onChange({ ...meta, [key]: val })
  }

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        gap: "6px",
        padding: "10px 12px",
        overflowY: "auto",
      }}
    >
      {fields.map((f) => (
        <div key={f.key} style={fieldStyle}>
          <label style={labelStyle}>{f.label}</label>
          {f.key === "description" ? (
            <textarea
              value={meta[f.key]}
              onChange={(e) => update(f.key, e.target.value)}
              placeholder={f.placeholder}
              rows={3}
              style={{
                ...inputStyle,
                resize: "vertical",
                minHeight: "48px",
              }}
            />
          ) : (
            <input
              type="text"
              value={meta[f.key]}
              onChange={(e) => update(f.key, e.target.value)}
              placeholder={f.placeholder}
              style={inputStyle}
            />
          )}
        </div>
      ))}
    </div>
  )
}
