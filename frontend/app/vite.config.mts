import react from "@vitejs/plugin-react"
import path from "path"
import { defineConfig } from "vite"
import svgr from "vite-plugin-svgr"
import wails from "@wailsio/runtime/plugins/vite"

export default defineConfig({
  plugins: [
    react(),
    wails("../bindings"),
    svgr({
      include: "**/*.svg",
      svgrOptions: {
        plugins: ["@svgr/plugin-svgo", "@svgr/plugin-jsx"],
        exportType: "default",
      },
    }),
  ],
  base: "./",
  build: {
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, "index.html"),
      },
    },
    minify: false,
    sourcemap: true,
    outDir: "../dist",
    emptyOutDir: true,
  },
  publicDir: "public",
  server: {
    host: "127.0.0.1",
    port: Number(process.env.WAILS_VITE_PORT) || 9245,
    strictPort: true,
  },
  resolve: {
    alias: {
      react: path.resolve("../node_modules/react"),
    },
    dedupe: ["react", "react-dom"],
  },
})
