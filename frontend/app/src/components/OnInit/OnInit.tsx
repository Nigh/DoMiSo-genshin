import { useProgress } from "dialog-hooks"
import { FC, useEffect, useState } from "react"
import { useStores } from "../../hooks/useStores"
import { useLocalization } from "../../localize/useLocalization"
import { AutoSaveDialog } from "../AutoSaveDialog/AutoSaveDialog"
import { InitializeErrorDialog } from "./InitializeErrorDialog"
import { useAutoSave } from "../../hooks/useAutoSave"

export const OnInit: FC = () => {
  const rootStore = useStores()

  const [isErrorDialogOpen, setIsErrorDialogOpen] = useState(false)
  const [errorMessage, setErrorMessage] = useState("")
  const [isAutoSaveDialogOpen, setIsAutoSaveDialogOpen] = useState(false)
  const { show: showProgress } = useProgress()
  const localized = useLocalization()
  const { shouldShowAutoSaveDialog } = useAutoSave()

  const init = async () => {
    const closeProgress = showProgress(localized["initializing"])
    try {
      await rootStore.init()
    } catch (e) {
      setIsErrorDialogOpen(true)
      setErrorMessage((e as Error).message)
    } finally {
      closeProgress()
    }
  }

  const checkAutoSave = async () => {
    if (shouldShowAutoSaveDialog()) {
      setIsAutoSaveDialogOpen(true)
    }
  }

  useEffect(() => {
    ;(async () => {
      await init()
      await checkAutoSave()
    })()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <>
      <InitializeErrorDialog
        open={isErrorDialogOpen}
        message={errorMessage}
        onClose={() => setIsErrorDialogOpen(false)}
      />
      <AutoSaveDialog
        open={isAutoSaveDialogOpen}
        onClose={() => setIsAutoSaveDialogOpen(false)}
      />
    </>
  )
}
