const C = {
  note: "#cdd6f4",
  rest: "#f38ba8",
  dur: "#94e2d5",
  chord: "#cba6f7",
  tuplet: "#f5c2e7",
  cmd: "#f9e2af",
  dim: "#585b70",
}

const SEP_RE = /^\s*={5,}\s*$/

function esc(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
}

function cs(color: string, text: string): string {
  return `<span style="color:${color}">${esc(text)}</span>`
}

export interface ActiveBracket {
  open: number
  close: number
  type: "(" | "{"
}

export function findEnclosingBracket(
  text: string,
  pos: number,
): ActiveBracket | null {
  for (let i = Math.min(pos, text.length); i >= 0; i--) {
    const ch = text[i]
    if (ch !== "(" && ch !== "{") continue
    const close = ch === "(" ? ")" : "}"
    let depth = 0
    for (let j = i; j < text.length; j++) {
      if (text[j] === ch) depth++
      else if (text[j] === close) {
        depth--
        if (depth === 0) {
          return pos >= i && pos <= j
            ? { open: i, close: j, type: ch as "(" | "{" }
            : null
        }
      }
    }
  }
  return null
}

function bcls(active: ActiveBracket | null, pos: number, type: "(" | "{"): string {
  const isActive = active != null && pos >= active.open && pos <= active.close && active.type === type
  if (type === "(") return isActive ? "chord-bg active" : "chord-bg"
  return isActive ? "tuplet-bg active" : "tuplet-bg"
}

interface Tok {
  text: string
  type: "ws" | "note" | "rest" | "co" | "cc" | "to" | "tc" | "cmd" | "other"
  pos: number
}

function tokenize(line: string): Tok[] {
  const tokens: Tok[] = []
  let i = 0
  while (i < line.length) {
    if (/\s/.test(line[i])) {
      const s = i
      while (i < line.length && /\s/.test(line[i])) i++
      tokens.push({ text: line.substring(s, i), type: "ws", pos: s })
      continue
    }
    if (line[i] === "(") {
      tokens.push({ text: "(", type: "co", pos: i })
      i++
      continue
    }
    if (line[i] === "{") {
      tokens.push({ text: "{", type: "to", pos: i })
      i++
      continue
    }
    if (line[i] === ")" || line[i] === "}") {
      const s = i
      const t = line[i] === ")" ? "cc" : "tc"
      i++
      while (i < line.length && /[/\-\.]/.test(line[i])) i++
      tokens.push({ text: line.substring(s, i), type: t, pos: s })
      continue
    }
    const nm = line.substring(i).match(/^(\~?)([-+]*)([0-7])([#b]?)([/\-\.]*)/)
    if (nm && nm[0].length > 0) {
      tokens.push({
        text: nm[0],
        type: nm[3] === "0" ? "rest" : "note",
        pos: i,
      })
      i += nm[0].length
      continue
    }
    const cm = line.substring(i).match(/^(bpm|rollback)\s*=\s*\S+/i)
    if (cm) {
      tokens.push({ text: cm[0], type: "cmd", pos: i })
      i += cm[0].length
      continue
    }
    const km = line.substring(i).match(/^1\s*=\s*[A-G]\d?[#b]?/i)
    if (km) {
      tokens.push({ text: km[0], type: "cmd", pos: i })
      i += km[0].length
      continue
    }
    const s = i
    while (i < line.length && !/[\s(){}]/.test(line[i])) i++
    if (i === s) i++
    tokens.push({ text: line.substring(s, i), type: "other", pos: s })
  }
  return tokens
}

function renderNote(text: string): string {
  const m = text.match(/^(\~?[-+]*[0-7][#b]?)([/\-\.]*)$/)
  if (!m) return cs(C.note, text)
  let out = cs(C.note, m[1])
  if (m[2]) out += cs(C.dur, m[2])
  return out
}

function renderRest(text: string): string {
  const m = text.match(/^(0)([/\-\.]*)$/)
  if (!m) return cs(C.rest, text)
  let out = cs(C.rest, m[1])
  if (m[2]) out += cs(C.dur, m[2])
  return out
}

function renderBracket(tok: Tok, cls: string, color: string, isOpen: boolean): string {
  const inner = cs(color, tok.text)
  if (isOpen) return `<span class="${cls}">${inner}`
  return `${inner}</span>`
}

function highlightNotationLine(line: string, active: ActiveBracket | null, lineOffset: number): string {
  const tokens = tokenize(line)
  let out = ""
  for (const tok of tokens) {
    switch (tok.type) {
      case "ws":
        out += tok.text
        break
      case "note":
        out += renderNote(tok.text)
        break
      case "rest":
        out += renderRest(tok.text)
        break
      case "co":
        out += renderBracket(tok, bcls(active, tok.pos, "("), C.chord, true)
        break
      case "cc":
        out += renderBracket(tok, bcls(active, tok.pos, "("), C.chord, false)
        break
      case "to":
        out += renderBracket(tok, bcls(active, tok.pos, "{"), C.tuplet, true)
        break
      case "tc":
        out += renderBracket(tok, bcls(active, tok.pos, "{"), C.tuplet, false)
        break
      case "cmd":
        out += cs(C.cmd, tok.text)
        break
      default:
        out += cs(C.dim, tok.text)
    }
  }
  return out
}

export function highlightDoMiSo(text: string, cursorPos?: number): string {
  const normalized = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n")
  const lines = normalized.split("\n")

  let active: ActiveBracket | null = null
  if (cursorPos != null) {
    active = findEnclosingBracket(normalized, cursorPos)
  }

  let inHeader = true
  let charOffset = 0
  const result: string[] = []

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]

    if (SEP_RE.test(line)) {
      inHeader = false
      result.push(cs(C.dim, line))
      charOffset += line.length + 1
      continue
    }

    if (inHeader) {
      const trimmed = line.trim()
      if (trimmed === "") {
        result.push("")
      } else {
        result.push(cs(C.dim, line))
      }
      charOffset += line.length + 1
      continue
    }

    const trimmed = line.trim()
    if (trimmed === "") {
      result.push("")
      charOffset += line.length + 1
      continue
    }

    if (/^\s*(#|\/\/)/.test(trimmed)) {
      result.push(cs(C.dim, line))
      charOffset += line.length + 1
      continue
    }

    result.push(highlightNotationLine(line, active, charOffset))
    charOffset += line.length + 1
  }

  return result.join("\n")
}
