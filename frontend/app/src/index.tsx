import { configure } from "mobx"
import { createRoot } from "react-dom/client"
import { App } from "./components/App/App"

configure({
  enforceActions: "never",
})

const root = createRoot(document.querySelector("#root")!)
root.render(<App />)
