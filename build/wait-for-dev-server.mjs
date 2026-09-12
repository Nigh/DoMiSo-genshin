const port = process.env.WAILS_VITE_PORT || "9245"
const url = `http://127.0.0.1:${port}`

for (let attempt = 0; attempt < 120; attempt++) {
  try {
    if ((await fetch(url)).ok) process.exit(0)
  } catch {}
  await new Promise((resolve) => setTimeout(resolve, 500))
}

throw new Error(`Frontend dev server did not start: ${url}`)
