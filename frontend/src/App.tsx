import React, { useCallback, useEffect, useRef, useState } from "react"
import { SheetEditor } from "./components/SheetEditor"
import { SheetSelector } from "./components/SheetSelector"
import { Toolbar } from "./components/Toolbar"
import { createSignalBridge, type SignalBridge } from "./bridge/signal-bridge"
import { AppService, SheetInfo } from "../bindings/domiso-universal"

function base64ToUint8Array(base64: string): Uint8Array {
  const binaryString = atob(base64)
  const bytes = new Uint8Array(binaryString.length)
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i)
  }
  return bytes
}

function App() {
  const [sheetText, setSheetText] = useState("")
  const [sheets, setSheets] = useState<SheetInfo[]>([])
  const [selectedSheet, setSelectedSheet] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [isSheetsLoading, setIsSheetsLoading] = useState(false)
  const [signalReady, setSignalReady] = useState(false)
  const [statusMessage, setStatusMessage] = useState("Loading signal...")
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
        setStatusMessage("Loaded - use signal controls to play")
      } else {
        setStatusMessage(`Error: ${error ?? "Failed to load MIDI"}`)
      }
    })

    return () => {
      bridge.dispose()
    }
  }, [])

  const handleSelectSheet = useCallback(
    async (sheet: SheetInfo) => {
      setSelectedSheet(sheet.path)
      try {
        const content = await AppService.LoadSheet(sheet.name)
        setSheetText(content)
      } catch (err) {
        console.error("Failed to load sheet:", err)
        setStatusMessage(`Error: Failed to load ${sheet.name}`)
      }
    },
    [],
  )

  const handleImport = useCallback(async () => {
    if (!sheetText.trim()) {
      setStatusMessage("Error: No sheet content to import")
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
    } catch (err) {
      console.error("Parse error:", err)
      setIsLoading(false)
      setStatusMessage(`Error: ${(err as Error).message ?? "Parse failed"}`)
    }
  }, [sheetText])

  return (
    <div
      style={{
        display: "flex",
        height: "100vh",
        backgroundColor: "#1e1e2e",
        color: "#cdd6f4",
        fontFamily:
          "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          width: "400px",
          minWidth: "300px",
          borderRight: "1px solid #313244",
          flexShrink: 0,
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
          }}
        >
          <span style={{ color: "#89b4fa" }}>DoMiSo</span>
          <span style={{ color: "#a6adc8", fontWeight: 400, fontSize: "12px" }}>
            Universal
          </span>
        </div>
        <div
          style={{
            height: "200px",
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
        <div style={{ flex: 1, overflow: "hidden" }}>
          <SheetEditor value={sheetText} onChange={setSheetText} />
        </div>
      </div>

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          flex: 1,
          overflow: "hidden",
        }}
      >
        <Toolbar
          onImport={handleImport}
          isLoading={isLoading}
          signalReady={signalReady}
          statusMessage={statusMessage}
        />
        <div style={{ flex: 1, position: "relative" }}>
          <iframe
            ref={iframeRef}
            src="./signal/edit.html"
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
      </div>
    </div>
  )
}

export default App
