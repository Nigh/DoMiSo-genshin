import styled from "@emotion/styled"
import { FC } from "react"
import { isEmbedded } from "../../helpers/platform"
import { useDisableBounceScroll } from "../../hooks/useDisableBounceScroll"
import { useDisableBrowserContextMenu } from "../../hooks/useDisableBrowserContextMenu"
import { useDisableZoom } from "../../hooks/useDisableZoom"
import { useGlobalKeyboardShortcut } from "../../hooks/useGlobalKeyboardShortcut"
import { useRouter } from "../../hooks/useRouter"
import { BuildInfo } from "../BuildInfo"
import { ControlSettingDialog } from "../ControlSettingDialog/ControlSettingDialog"
import { ExportProgressDialog } from "../ExportDialog/ExportProgressDialog"
import { Head } from "../Head/Head"
import { HelpDialog } from "../Help/HelpDialog"
import { Navigation } from "../Navigation/Navigation"
import { OnBeforeUnload } from "../OnBeforeUnload/OnBeforeUnload"
import { OnInit } from "../OnInit/OnInit"
import { PianoRollEditor } from "../PianoRoll/PianoRollEditor"
import { SettingDialog } from "../SettingDialog/SettingDialog"
import { TempoEditor } from "../TempoGraph/TempoEditor"
import { TransportPanel } from "../TransportPanel/TransportPanel"
import { DropZone } from "./DropZone"

const embedded = isEmbedded()

const Container = styled.div`
  height: 100%;
  display: flex;
  flex-direction: column;
  flex-grow: 1;
  overflow: hidden;
`

const Column = styled.div`
  height: 100%;
  display: flex;
  flex-grow: 1;
  flex-direction: column;
  outline: none;
`

const Routes: FC = () => {
  const { path } = useRouter()
  return (
    <>
      {path === "/track" && <PianoRollEditor />}
      {path === "/tempo" && <TempoEditor />}
    </>
  )
}

export const RootView: FC = () => {
  const keyboardShortcutProps = useGlobalKeyboardShortcut()
  useDisableZoom()
  useDisableBounceScroll()
  useDisableBrowserContextMenu()

  return (
    <>
      <DropZone>
        <Column {...keyboardShortcutProps} tabIndex={0}>
          {!embedded && <Navigation />}
          <Container>
            <Routes />
            {!embedded && <TransportPanel />}
            {!embedded && <BuildInfo />}
          </Container>
        </Column>
      </DropZone>
      {!embedded && <HelpDialog />}
      <ExportProgressDialog />
      <Head />
      {!embedded && <SettingDialog />}
      {!embedded && <ControlSettingDialog />}
      <OnInit />
      <OnBeforeUnload />
    </>
  )
}
