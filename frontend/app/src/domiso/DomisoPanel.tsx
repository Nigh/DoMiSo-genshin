import { Dialogs } from "@wailsio/runtime"
import { useCallback, useEffect, useState } from "react"
import { AppService } from "../../../bindings/domiso-universal"
import { useMobxGetter } from "../hooks/useMobxSelector"
import { useStores } from "../hooks/useStores"
import { CodeEditor } from "./components/CodeEditor"
import { MetaEditor } from "./components/MetaEditor"
import styled from "@emotion/styled"
import { Button } from "../components/ui/Button"
import { Select } from "../components/ui/Select"

const Panel = styled.aside`
  width: 380px;
  min-width: 280px;
  display: flex;
  flex-direction: column;
  border-right: 1px solid var(--color-divider);
  background: var(--color-background);
`

const Toolbar = styled.div`
  display: flex;
  gap: 0.4rem;
  padding: 0.5rem;
  border-bottom: 1px solid var(--color-divider);
`

type Meta = {
  title: string
  composer: string
  arranger: string
  description: string
  tempo: string
  timeSig: string
  key: string
}

const emptyMeta: Meta = {
  title: "",
  composer: "",
  arranger: "",
  description: "",
  tempo: "",
  timeSig: "",
  key: "",
}

function fromBase64(value: string) {
  const raw = atob(value)
  return Uint8Array.from(raw, (char) => char.charCodeAt(0))
}

function toBase64(value: Uint8Array) {
  let raw = ""
  for (const byte of value) raw += String.fromCharCode(byte)
  return btoa(raw)
}

export function DomisoPanel() {
  const { songStore, player } = useStores()
  const songSaved = useMobxGetter(songStore.song, "isSaved")
  const outOfSync = useMobxGetter(songStore, "notationOutOfSync")
  const [notation, setNotation] = useState("")
  const [meta, setMeta] = useState<Meta>(emptyMeta)
  const [message, setMessage] = useState("载入曲谱后可在卷帘中编辑")
  const [sheets, setSheets] = useState<{ name: string; path: string }[]>([])

  useEffect(() => {
    AppService.ListFreeSheets().then(setSheets).catch(() => setSheets([]))
  }, [])

  const loadMIDI = useCallback(
    (bytes: Uint8Array, generatedFromNotation: boolean, reference = false) => {
      player.stop()
      player.reset()
      songStore.loadMIDI(bytes, {
        notation,
        generatedFromNotation,
        notationOutOfSync: reference,
      })
      player.position = 0
    },
    [notation, player, songStore],
  )

  const regenerate = useCallback(async () => {
    if (!notation.trim()) return
    if (!songSaved) {
      setMessage("请先保存或丢弃当前 MIDI 修改")
      return
    }
    try {
      loadMIDI(fromBase64(await AppService.ParseTextToMIDI(notation)), true)
      setMessage("已从 DoMiSo 生成 MIDI")
    } catch (error) {
      setMessage(`解析失败：${String(error)}`)
    }
  }, [loadMIDI, notation, songSaved])

  const open = useCallback(async () => {
    const filePath = await Dialogs.OpenFile({
      Title: "打开曲谱",
      Filters: [{ DisplayName: "曲谱", Pattern: "*.txt;*.json;*.dms" }],
    })
    if (!filePath) return
    try {
      const result = await AppService.ImportSheet(filePath)
      const text = result.content ?? ""
      setNotation(text)
      setMeta((result.meta as Meta) ?? emptyMeta)
      if (result.midi) {
        player.stop()
        songStore.loadMIDI(fromBase64(result.midi), {
          notation: text,
          notationOutOfSync: result.notationOutOfSync,
        })
      } else {
        const midi = await AppService.ParseTextToMIDI(text)
        player.stop()
        songStore.loadMIDI(fromBase64(midi), {
          notation: text,
          generatedFromNotation: true,
        })
      }
      player.position = 0
      setMessage("曲谱已载入")
    } catch (error) {
      setMessage(`打开失败：${String(error)}`)
    }
  }, [player, songStore])

  const save = useCallback(async () => {
    const persistMIDI = !songStore.generatedFromNotation || songStore.notationOutOfSync
    const filePath = await Dialogs.SaveFile({
      Title: "保存曲谱",
      Filename: `${meta.title || "sheet"}.${persistMIDI ? "json" : "txt"}`,
      Filters: persistMIDI
        ? [{ DisplayName: "DoMiSo 项目", Pattern: "*.json" }]
        : [
            { DisplayName: "DoMiSo 文本", Pattern: "*.txt" },
            { DisplayName: "DoMiSo 项目", Pattern: "*.json" },
          ],
    })
    if (!filePath) return
    try {
      await AppService.ExportSheet(
        filePath,
        meta,
        notation,
        persistMIDI ? toBase64(songStore.midiBytes) : "",
        songStore.notationOutOfSync,
      )
      songStore.markSaved()
      setMessage("已保存")
    } catch (error) {
      setMessage(`保存失败：${String(error)}`)
    }
  }, [meta, notation, songStore])

  useEffect(() => {
    if (outOfSync) setMessage("MIDI 已修改，DoMiSo 文本仅供参考")
  }, [outOfSync])

  return (
    <Panel>
      <Toolbar>
        <Button onClick={open}>打开</Button>
        <Button onClick={save}>保存</Button>
        <Button onClick={regenerate} disabled={!songSaved}>从文本重新生成</Button>
      </Toolbar>
      <div style={{ margin: "0.5rem" }}><Select defaultValue="" onChange={async (event) => {
        if (!event.target.value) return
        try {
          const text = await AppService.LoadSheet(event.target.value)
          const midi = await AppService.ParseTextToMIDI(text)
          setNotation(text)
          player.stop()
          songStore.loadMIDI(fromBase64(midi), { notation: text, generatedFromNotation: true })
          player.position = 0
          setMessage("示例曲谱已载入")
        } catch (error) {
          setMessage(`载入失败：${String(error)}`)
        }
      }}>
        <option value="">选择内置曲谱…</option>
        {sheets.map((sheet) => <option key={sheet.path} value={sheet.path}>{sheet.name}</option>)}
      </Select></div>
      {outOfSync && <strong style={{ padding: "0 8px", color: "#f9a825" }}>文本与 MIDI 不一致，仅供参考</strong>}
      <details style={{ padding: "0 8px 8px" }}>
        <summary>曲谱信息</summary>
        <MetaEditor meta={meta} onChange={setMeta} />
      </details>
      <div style={{ flex: 1, minHeight: 0 }}>
        <CodeEditor value={notation} onChange={setNotation} />
      </div>
      <small style={{ padding: 8 }}>{message}</small>
    </Panel>
  )
}
