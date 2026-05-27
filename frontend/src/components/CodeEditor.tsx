import React, {
  useCallback,
  useEffect,
  useLayoutEffect,
  useMemo,
  useRef,
  useState,
} from "react"
import { highlightDoMiSo } from "../utils/highlight"

interface CodeEditorProps {
  value: string
  onChange: (value: string) => void
}

export function CodeEditor({ value, onChange }: CodeEditorProps) {
  const scrollRef = useRef<HTMLDivElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const preRef = useRef<HTMLPreElement>(null)
  const [cursorPos, setCursorPos] = useState<number | undefined>(undefined)

  const highlighted = useMemo(
    () => highlightDoMiSo(value, cursorPos),
    [value, cursorPos],
  )

  useLayoutEffect(() => {
    const ta = textareaRef.current
    const pre = preRef.current
    if (!ta || !pre) return
    const sync = () => {
      ta.style.height = pre.scrollHeight + "px"
    }
    const ro = new ResizeObserver(sync)
    ro.observe(pre)
    sync()
    return () => ro.disconnect()
  }, [highlighted])

  const updateCursor = useCallback(() => {
    const ta = textareaRef.current
    if (ta) setCursorPos(ta.selectionStart)
  }, [])

  const scrollCaretIntoView = useCallback(() => {
    const ta = textareaRef.current
    const sc = scrollRef.current
    if (!ta || !sc) return
    const pos = ta.selectionStart
    if (pos == null) return
    const lines = ta.value.substring(0, pos).split("\n")
    const lineNum = lines.length - 1
    const computed = getComputedStyle(ta)
    const lineHeight = parseFloat(computed.lineHeight) || 22.4
    const paddingTop = parseFloat(computed.paddingTop) || 0
    const caretY = paddingTop + lineNum * lineHeight
    const caretH = lineHeight
    const viewTop = sc.scrollTop
    const viewBottom = viewTop + sc.clientHeight
    const margin = lineHeight * 2
    if (caretY < viewTop + margin) {
      sc.scrollTop = Math.max(0, caretY - margin)
    } else if (caretY + caretH > viewBottom - margin) {
      sc.scrollTop = caretY + caretH - sc.clientHeight + margin
    }
  }, [])

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLTextAreaElement>) => {
      onChange(e.target.value)
      requestAnimationFrame(scrollCaretIntoView)
    },
    [onChange, scrollCaretIntoView],
  )

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === "Tab") {
        e.preventDefault()
        const ta = e.currentTarget
        const start = ta.selectionStart
        const end = ta.selectionEnd
        const nv = value.substring(0, start) + "\t" + value.substring(end)
        onChange(nv)
        requestAnimationFrame(() => {
          ta.selectionStart = ta.selectionEnd = start + 1
          scrollCaretIntoView()
          updateCursor()
        })
      } else {
        requestAnimationFrame(() => {
          scrollCaretIntoView()
          updateCursor()
        })
      }
    },
    [value, onChange, scrollCaretIntoView, updateCursor],
  )

  useEffect(() => {
    const id = "domiso-editor-style"
    if (document.getElementById(id)) return
    const el = document.createElement("style")
    el.id = id
    el.textContent = `
      .domiso-scroll::-webkit-scrollbar { width: 14px; }
      .domiso-scroll::-webkit-scrollbar-track { background: transparent; }
      .domiso-scroll::-webkit-scrollbar-thumb {
        background: #45475a; border-radius: 7px; border: 3px solid #1e1e2e;
      }
      .domiso-scroll::-webkit-scrollbar-thumb:hover { background: #585b70; }
      .domiso-scroll::-webkit-scrollbar-corner { background: transparent; }
      .chord-bg { background: rgba(203,166,247,0.06); border-radius: 2px; }
      .tuplet-bg { background: rgba(245,194,231,0.06); border-radius: 2px; }
      .chord-bg.active {
        background: rgba(203,166,247,0.15);
        box-shadow: 0 0 0 1px rgba(203,166,247,0.4);
        border-radius: 2px;
      }
      .tuplet-bg.active {
        background: rgba(245,194,231,0.15);
        box-shadow: 0 0 0 1px rgba(245,194,231,0.4);
        border-radius: 2px;
      }
    `
    document.head.appendChild(el)
  }, [])

  const font: React.CSSProperties = {
    fontFamily: "'Roboto Mono', 'Consolas', 'Courier New', monospace",
    fontSize: "14px",
    lineHeight: "1.6",
    tabSize: 4,
    whiteSpace: "pre-wrap",
    wordBreak: "break-all",
    overflowWrap: "break-word",
  }

  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
        backgroundColor: "#1e1e2e",
      }}
    >
      <div
        ref={scrollRef}
        className="domiso-scroll"
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          overflowY: "auto",
          overflowX: "hidden",
        }}
      >
        <pre
          ref={preRef}
          aria-hidden="true"
          style={{
            ...font,
            margin: 0,
            padding: "16px",
            border: "none",
            outline: "none",
            boxSizing: "border-box",
            color: "#cdd6f4",
            backgroundColor: "transparent",
            pointerEvents: "none",
          }}
          dangerouslySetInnerHTML={{ __html: highlighted + "\n" }}
        />
        <textarea
          ref={textareaRef}
          value={value}
          onChange={handleChange}
          onKeyDown={handleKeyDown}
          onClick={(e) => {
            scrollCaretIntoView()
            updateCursor()
          }}
          onSelect={updateCursor}
          spellCheck={false}
          autoComplete="off"
          autoCorrect="off"
          autoCapitalize="off"
          style={{
            ...font,
            position: "absolute",
            top: 0,
            left: 0,
            width: "100%",
            padding: "16px",
            margin: 0,
            boxSizing: "border-box",
            border: "none",
            outline: "none",
            resize: "none",
            overflow: "hidden",
            backgroundColor: "transparent",
            color: "transparent",
            caretColor: "#f5e0dc",
            WebkitTextFillColor: "transparent",
          }}
        />
      </div>
    </div>
  )
}
