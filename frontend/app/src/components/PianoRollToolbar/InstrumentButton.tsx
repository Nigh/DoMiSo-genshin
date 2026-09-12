import { type FC, useState } from "react"
import { usePianoRoll } from "../../hooks/usePianoRoll"
import { useTrack } from "../../hooks/useTrack"
import { categoryEmojis, getCategoryIndex } from "../../midi/GM"
import { InstrumentBrowser } from "../InstrumentBrowser/InstrumentBrowser"
import { ToolbarButton } from "../Toolbar/ToolbarButton"
import { InstrumentName } from "../TrackList/InstrumentName"

export const InstrumentButton: FC = () => {
  const { selectedTrackId } = usePianoRoll()
  const { isRhythmTrack, programNumber } = useTrack(selectedTrackId)
  const [isOpen, setOpen] = useState(false)

  const emoji = isRhythmTrack
    ? "🥁"
    : categoryEmojis[getCategoryIndex(programNumber ?? 0)]

  return (
    <>
      <ToolbarButton
        onMouseDown={(e) => {
          e.preventDefault()
          setOpen(true)
        }}
      >
        <span style={{ marginRight: "0.5rem" }}>{emoji}</span>
        <span>
          <InstrumentName
            programNumber={programNumber}
            isRhythmTrack={isRhythmTrack}
          />
        </span>
      </ToolbarButton>
      <InstrumentBrowser
        isOpen={isOpen}
        onOpenChange={setOpen}
        trackId={selectedTrackId}
        showInsertButton={true}
      />
    </>
  )
}
