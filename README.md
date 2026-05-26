# DoMiSo Universal

A DoMiSo notation player with built-in piano roll visualization and playback, powered by [signal](https://github.com/ryohey/signal).

## Overview

DoMiSo Universal parses text-based music notation (DoMiSo format) and renders it in a piano roll for visual preview and audio playback. It ships with embedded sample sheets and supports writing custom notation directly in the editor.

## Architecture

- **Go backend** (Wails 3): Parses DoMiSo notation via [domiso-parser](https://github.com/Nigh/domiso-parser), generates standard MIDI
- **Signal piano roll** (iframe): [signal](https://github.com/ryohey/signal) MIDI editor for visualization and playback
- **React frontend**: Text editor, sheet selector, and signal integration via postMessage bridge

```
Text notation → domiso-parser → MIDI bytes → postMessage → signal piano roll → playback
```

## Building

### Prerequisites

- Go 1.25+
- Node.js 22+
- Wails 3 CLI (`go install github.com/wailsapp/wails/v3/cmd/wails3@latest`)

### Build Steps

```bash
# 1. Build signal piano roll (one-time setup)
task build:signal

# 2. Build the application
task build

# Or manually:
# Build signal
cd signal && npm install && npm run build -w packages/player && npm run build -w packages/dialog-hooks && npm run build -w app && cd ..
# Copy signal dist to frontend
cp -r signal/app/dist/* frontend/public/signal/
# Build frontend
cd frontend && npm install && npm run build && cd ..
# Build Go binary
wails3 build
```

### Development

```bash
task dev
```

## DoMiSo Notation Syntax

See [SYNTAX.md](SYNTAX.md) for the complete notation reference.

Quick example:
```
1=C 4/4 120
1 2 3 4 | 5 6 7 1̇
[135] [246] [357] [461̇]
```

## Sample Sheets

8 sample sheets are embedded in the binary, including:
- A Sweet Smile (甜美的微笑)
- He's a Pirate
- Snow halation (Love Live)
- Always With Me (千与千寻)
- And more...

## Licenses

### DoMiSo Universal

MIT License - Copyright (c) 2021 Nigh

See [LICENSE](LICENSE) for details.

### Signal (piano roll component)

The embedded piano roll is based on [signal](https://github.com/ryohey/signal) by ryohey.

MIT License - Copyright (c) 2016 ryohey

```
The MIT License (MIT)

Copyright (c) 2016 ryohey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### domiso-parser

[domiso-parser](https://github.com/Nigh/domiso-parser) - DoMiSo text notation parser

### SoundFont

The bundled SoundFont (`A320U.sf2`, `A320U_drums.sf2`) is from the signal project.

## Communities

- Discord (Global): https://discord.gg/5PCebykNaC
- KOOK (Mainland China): https://kook.top/VXCE5O
