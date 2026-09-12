import {
  DialogProvider,
  ProgressProvider,
  PromptProvider,
  ToastProvider,
} from "dialog-hooks"
import React from "react"
import { HelmetProvider } from "react-helmet-async"
import { ActionDialog } from "../../components/Dialog/ActionDialog"
import { PianoRollProvider } from "../../hooks/usePianoRoll"
import { StoreContext } from "../../hooks/useStores"
import { TempoEditorProvider } from "../../hooks/useTempoEditor"
import { TrackMuteProvider } from "../../hooks/useTrackMute"
import RootStore from "../../stores/RootStore"
import { ThemeProvider } from "../../theme/ThemeProvider"
import { ProgressDialog } from "../Dialog/ProgressDialog"
import { PromptDialog } from "../Dialog/PromptDialog"
import { RootView } from "../RootView/RootView"
import { GlobalCSS } from "../Theme/GlobalCSS"
import { Toast } from "../ui/Toast"
import { LocalizationProvider } from "./LocalizationProvider"
import { DomisoPanel } from "../../domiso/DomisoPanel"
import { PerformancePanel } from "../../performance/PerformancePanel"

export const rootStore = new RootStore()

export function App() {
  return (
    <React.StrictMode>
      <StoreContext.Provider value={rootStore}>
        <ThemeProvider>
          <HelmetProvider>
            <ToastProvider component={Toast}>
              <PromptProvider component={PromptDialog}>
                <DialogProvider component={ActionDialog}>
                  <ProgressProvider component={ProgressDialog}>
                    <LocalizationProvider>
                      <TrackMuteProvider>
                        <PianoRollProvider>
                          <TempoEditorProvider>
                            <GlobalCSS />
                            <div style={{ display: "flex", height: "100vh", width: "100vw" }}>
                              <DomisoPanel />
                              <div style={{ display: "flex", flex: 1, minWidth: 0 }}>
                                <RootView />
                              </div>
                              <PerformancePanel />
                            </div>
                          </TempoEditorProvider>
                        </PianoRollProvider>
                      </TrackMuteProvider>
                    </LocalizationProvider>
                  </ProgressProvider>
                </DialogProvider>
              </PromptProvider>
            </ToastProvider>
          </HelmetProvider>
        </ThemeProvider>
      </StoreContext.Provider>
    </React.StrictMode>
  )
}
