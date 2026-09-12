import { TrackId } from "@signal-app/core"
import { useEffect, useRef } from "react"
import { useStores } from "./useStores"

/**
 * Returns a ref to attach to the indicator element.
 * Triggers a CSS animation restart via direct DOM manipulation (no re-renders).
 */
export const useMIDIActivityIndicator = (trackId: TrackId) => {
  const { midiActivity } = useStores()
  const indicatorRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    return midiActivity.onActivity((trackIds) => {
      if (!trackIds.includes(trackId)) return
      const el = indicatorRef.current
      if (!el) return
      // Restart the CSS animation by removing the data-active attribute,
      // forcing a reflow, then re-adding it.
      el.removeAttribute("data-active")
      void el.offsetWidth
      el.setAttribute("data-active", "true")
    })
  }, [midiActivity, trackId])

  return indicatorRef
}
