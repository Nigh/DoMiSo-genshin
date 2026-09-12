import { z } from "zod"
import { genshinWindsongLyre } from "./genshin"
import type { GameInstrumentProfile } from "./types"

const transitionSchema = z.object({
  from: z.string().min(1), to: z.string().min(1), keyCode: z.string().min(1), scanCode: z.number().int().positive().max(0xffff),
})
const profileSchema = z.object({
  version: z.literal(1),
  id: z.string().min(1),
  name: z.string().min(1),
  processNames: z.array(z.string().min(1)).min(1),
  initialState: z.string().min(1),
  states: z.array(z.object({ id: z.string().min(1), label: z.string(), bindings: z.record(z.string(), z.number().int().min(0).max(127)) })).min(1),
  transitions: z.array(transitionSchema),
  scanCodes: z.record(z.string(), z.number().int().positive().max(0xffff)),
  timing: z.object({ keyDownMs: z.number().int().min(1).max(1000), chordGapMs: z.number().int().min(0).max(1000), stateSwitchDelayMs: z.number().int().min(0).max(5000) }),
}).superRefine((profile, context) => {
  const states = new Set(profile.states.map((state) => state.id))
  if (!states.has(profile.initialState)) context.addIssue({ code: "custom", message: "initialState 不存在" })
  for (const state of profile.states) {
    for (const key of Object.keys(state.bindings)) {
      if (!profile.scanCodes[key]) context.addIssue({ code: "custom", message: `${key} 缺少 scanCode` })
    }
  }
  for (const transition of profile.transitions) {
    if (!states.has(transition.from) || !states.has(transition.to)) context.addIssue({ code: "custom", message: "状态迁移引用了不存在的状态" })
  }
})

const storageKey = "domiso.gameInstrumentProfiles.v1"

export function parseProfile(value: string): GameInstrumentProfile {
  return profileSchema.parse(JSON.parse(value)) as GameInstrumentProfile
}

export function loadProfiles(): GameInstrumentProfile[] {
  try {
    const custom = z.array(profileSchema).parse(JSON.parse(localStorage.getItem(storageKey) ?? "[]"))
    return [genshinWindsongLyre, ...custom.filter((item) => item.id !== genshinWindsongLyre.id)] as GameInstrumentProfile[]
  } catch {
    return [genshinWindsongLyre]
  }
}

export function saveCustomProfiles(profiles: GameInstrumentProfile[]) {
  localStorage.setItem(storageKey, JSON.stringify(profiles.filter((item) => item.id !== genshinWindsongLyre.id)))
}
