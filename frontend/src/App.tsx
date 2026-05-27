import React, { useCallback, useEffect, useRef, useState } from "react"
import { CodeEditor } from "./components/CodeEditor"
import { SheetSelector } from "./components/SheetSelector"
import { MetaEditor } from "./components/MetaEditor"
import { StatusBar } from "./components/StatusBar"
import { Toolbar, type AppMode } from "./components/Toolbar"
import {
  createSignalBridge,
  type PlayerState,
  type SignalBridge,
} from "./bridge/signal-bridge"
import { AppService, SheetInfo, SheetMeta, SheetStats } from "../bindings/domiso-universal"
import { Dialogs } from "@wailsio/runtime"

function base64ToUint8Array(base64: string): Uint8Array {
  const binaryString = atob(base64)
  const bytes = new Uint8Array(binaryString.length)
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i)
  }
  return bytes
}

const emptyMeta: SheetMeta = {
  title: "",
  composer: "",
  arranger: "",
  description: "",
  tempo: "",
  timeSig: "",
  key: "",
}

function normalizeLineEndings(s: string): string {
  return s.replace(/\r\n/g, "\n").replace(/\r/g, "\n")
}

function parseHeaderMeta(text: string): SheetMeta {
  const lines = text.split("\n")
  const meta = { ...emptyMeta }
  for (const line of lines) {
    if (/^\s*={5,}\s*$/.test(line)) break
    const colonIdx = line.indexOf(":")
    if (colonIdx <= 0 || colonIdx > 10) continue
    const key = line.substring(0, colonIdx).trim()
    const val = line.substring(colonIdx + 1).trim()
    switch (key) {
      case "标题":
        meta.title = val
        break
      case "记谱":
        meta.composer = val
        break
      case "编曲":
        meta.arranger = val
        break
    }
  }
  return meta
}

function App() {
  const [sheetText, setSheetText] = useState("")
  const [meta, setMeta] = useState<SheetMeta>({ ...emptyMeta })
  const [sheets, setSheets] = useState<SheetInfo[]>([])
  const [selectedSheet, setSelectedSheet] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [isSheetsLoading, setIsSheetsLoading] = useState(false)
  const [signalReady, setSignalReady] = useState(false)
  const [statusMessage, setStatusMessage] = useState("Loading signal...")
  const [mode, setMode] = useState<AppMode>("editor")
  const [playerState, setPlayerState] = useState<PlayerState | null>(null)
  const [songLoaded, setSongLoaded] = useState(false)
  const [sheetStats, setSheetStats] = useState<SheetStats | null>(null)
  const [sheetFormat, setSheetFormat] = useState<string>("txt")
  const iframeRef = useRef<HTMLIFrameElement>(null)
  const bridgeRef = useRef<SignalBridge | null>(null)

  const loadSheets = useCallback(async () => {
    setIsSheetsLoading(true)
    try {
      const sheetList = await AppService.ListFreeSheets()
      setSheets(sheetList)
    } catch (err) {
      console.error("Failed to load sheets:", err)
      setStatusMessage("Error: Failed to load sheet list")
    } finally {
      setIsSheetsLoading(false)
    }
  }, [])

  useEffect(() => {
    loadSheets()
  }, [loadSheets])

  useEffect(() => {
    const iframe = iframeRef.current
    if (!iframe) return

    const bridge = createSignalBridge(iframe)
    bridgeRef.current = bridge

    bridge.onReady(() => {
      setSignalReady(true)
      setStatusMessage("Signal ready")
    })

    bridge.onMIDILoaded((success, error) => {
      setIsLoading(false)
      if (success) {
        setStatusMessage("Loaded")
        setSongLoaded(true)
      } else {
        setStatusMessage(`Error: ${error ?? "Failed to load MIDI"}`)
      }
    })

    bridge.onStateUpdate((state) => {
      setPlayerState(state)
    })

    bridge.onSongLoaded((songMeta) => {
      setSongLoaded(true)
      setPlayerState((prev) =>
        prev
          ? { ...prev, endOfSong: songMeta.endOfSong }
          : {
              isPlaying: false,
              position: 0,
              endOfSong: songMeta.endOfSong,
              tempo: 120,
              mbtTime: "1:1:0",
            },
      )
    })

    return () => {
      bridge.dispose()
    }
  }, [])

  useEffect(() => {
    if (!sheetText.trim()) {
      setSheetStats(null)
      return
    }
    let cancelled = false
    AppService.ParseSheetStats(sheetText)
      .then((stats) => {
        if (!cancelled) setSheetStats(stats as SheetStats)
      })
      .catch(() => {
        if (!cancelled) setSheetStats(null)
      })
    return () => {
      cancelled = true
    }
  }, [sheetText])

  const handleSelectSheet = useCallback(
    async (sheet: SheetInfo) => {
      setSelectedSheet(sheet.path)
      try {
        const content = await AppService.LoadSheet(sheet.path)
        const normalized = normalizeLineEndings(content)
        setSheetText(normalized)
        setMeta(parseHeaderMeta(normalized))
        setSheetFormat("txt")
      } catch (err) {
        console.error("Failed to load sheet:", err)
        setStatusMessage(`Error: Failed to load ${sheet.name}`)
      }
    },
    [],
  )

  const handleSync = useCallback(async () => {
    if (!sheetText.trim()) {
      setStatusMessage("Error: No sheet content to sync")
      return
    }
    if (!bridgeRef.current) {
      setStatusMessage("Error: Signal bridge not initialized")
      return
    }

    setIsLoading(true)
    setStatusMessage("Parsing notation...")

    try {
      const midiBase64 = await AppService.ParseTextToMIDI(sheetText)
      const midiBytes = base64ToUint8Array(midiBase64)
      setStatusMessage("Sending to piano roll...")
      bridgeRef.current.loadMIDI(midiBytes)
      setMode("piano-roll")
    } catch (err) {
      console.error("Parse error:", err)
      setIsLoading(false)
      setStatusMessage(`Error: ${(err as Error).message ?? "Parse failed"}`)
    }
  }, [sheetText])

  const handleImportFile = useCallback(async () => {
    try {
      const filePath = await Dialogs.OpenFile({
        Title: "Open Sheet",
        Filters: [
          { DisplayName: "All Supported", Pattern: "*.txt;*.json;*.dms" },
          { DisplayName: "DoMiSo Text", Pattern: "*.txt" },
          { DisplayName: "JSON Sheet", Pattern: "*.json" },
          { DisplayName: "DMS Encrypted", Pattern: "*.dms" },
        ],
      })
      if (!filePath) return

      const result = (await AppService.ImportSheet(filePath)) as {
        content: string
        meta: SheetMeta
        format: string
      }
      setSheetText(normalizeLineEndings(result.content))
      setMeta(result.meta)
      setSheetFormat(result.format)
      setSelectedSheet(null)
      setStatusMessage(`Loaded: ${filePath.split(/[/\\]/).pop()}`)
    } catch (err) {
      console.error("Import error:", err)
      setStatusMessage(`Error: ${(err as Error).message ?? "Import failed"}`)
    }
  }, [])

  const handleExportFile = useCallback(async () => {
    try {
      const filePath = await Dialogs.SaveFile({
        Title: "Save Sheet",
        Filename: meta.title ? `${meta.title}.json` : "sheet.json",
        Filters: [
          { DisplayName: "JSON Sheet", Pattern: "*.json" },
          { DisplayName: "DoMiSo Text", Pattern: "*.txt" },
        ],
      })
      if (!filePath) return

      await AppService.ExportSheet(filePath, meta, sheetText)
      setStatusMessage(`Saved: ${filePath.split(/[/\\]/).pop()}`)
    } catch (err) {
      console.error("Export error:", err)
      setStatusMessage(`Error: ${(err as Error).message ?? "Export failed"}`)
    }
  }, [meta, sheetText])

  const handlePlay = useCallback(() => {
    bridgeRef.current?.play()
  }, [])

  const handleStop = useCallback(() => {
    bridgeRef.current?.stop()
  }, [])

  const handleSeek = useCallback((tick: number) => {
    bridgeRef.current?.seek(tick)
  }, [])

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        height: "100vh",
        backgroundColor: "#1e1e2e",
        color: "#cdd6f4",
        fontFamily:
          "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
      }}
    >
      <Toolbar
        onSync={handleSync}
        isLoading={isLoading}
        signalReady={signalReady}
        statusMessage={statusMessage}
        mode={mode}
        onModeChange={setMode}
        playerState={playerState}
        songLoaded={songLoaded}
        onPlay={handlePlay}
        onStop={handleStop}
        onSeek={handleSeek}
        onImportFile={handleImportFile}
        onExportFile={handleExportFile}
      />

      <div style={{ display: "flex", flex: 1, overflow: "hidden" }}>
        {mode === "editor" && (
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              width: "320px",
              minWidth: "240px",
              borderRight: "1px solid #313244",
              flexShrink: 0,
              overflow: "hidden",
            }}
          >
            <div
              style={{
                padding: "12px 16px",
                borderBottom: "1px solid #313244",
                fontWeight: 800,
                fontSize: "16px",
                display: "flex",
                alignItems: "center",
                gap: "8px",
                flexShrink: 0,
              }}
            >
              <span style={{ color: "#89b4fa" }}>DoMiSo</span>
              <span
                style={{
                  color: "#a6adc8",
                  fontWeight: 400,
                  fontSize: "12px",
                }}
              >
                Universal
              </span>
            </div>
            <div
              style={{
                height: "180px",
                borderBottom: "1px solid #313244",
                flexShrink: 0,
                overflow: "hidden",
              }}
            >
              <SheetSelector
                sheets={sheets}
                selectedSheet={selectedSheet}
                onSelect={handleSelectSheet}
                onRefresh={loadSheets}
                isLoading={isSheetsLoading}
              />
            </div>
            <div
              style={{
                flex: 1,
                overflow: "hidden",
                borderTop: "1px solid #313244",
              }}
            >
              <MetaEditor meta={meta} onChange={setMeta} />
            </div>
          </div>
        )}

        <div
          style={{
            flex: 1,
            position: "relative",
            display: mode === "piano-roll" ? "block" : "none",
          }}
        >
          <iframe
            ref={iframeRef}
            src="./signal/edit.html?embed=true"
            style={{
              width: "100%",
              height: "100%",
              border: "none",
              display: "block",
            }}
            title="Signal Piano Roll"
            allow="midi; autoplay"
          />
        </div>

        {mode === "editor" && (
          <div
            style={{
              flex: 1,
              display: "flex",
              flexDirection: "column",
              overflow: "hidden",
            }}
          >
            <div style={{ flex: 1, overflow: "hidden" }}>
              <CodeEditor value={sheetText} onChange={setSheetText} />
            </div>
            <StatusBar stats={sheetStats} format={sheetFormat} />
          </div>
        )}
      </div>
    </div>
  )
}

export default App
