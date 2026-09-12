export function getPlatform() {
  const platform = navigator.platform.toLowerCase()
  let os = null

  if (platform.indexOf("win") >= 0) {
    os = "Windows"
  } else if (platform.indexOf("mac") >= 0) {
    os = "macOS"
  }

  return os
}

export function isRunningInElectron() {
  // Check if we are running in Electron using the user agent
  return navigator.userAgent.toLowerCase().indexOf(" electron/") > -1
}

export function isEmbedded() {
  const params = new URLSearchParams(window.location.search)
  if (params.get("embed") === "true") return true
  try {
    return window.parent !== window
  } catch {
    return true
  }
}
