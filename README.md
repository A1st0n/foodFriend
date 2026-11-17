# foodFriend: Whisper in React

A Vite + React app that runs OpenAI's open-source **Whisper** speech-to-text model entirely in the browser. It uses [Transformers.js](https://huggingface.co/docs/transformers.js) (ONNX Runtime Web) with the `Xenova/whisper-tiny.en` weights. There's no server and no API key, and your audio never leaves the machine.

```bash
npm install
npm run dev
```

Open the page and choose an audio file. The first run downloads the model (about 40 MB), and after that the browser caches it. For better accuracy, change the model id in `src/App.jsx`. For example, use `Xenova/whisper-base` or `onnx-community/whisper-large-v3-turbo`, which are larger and slower.

## The code, line by line (`src/App.jsx`)

The whole app is about 40 lines in one component. Everything else is the stock Vite React template.

| Lines | Code | Why it's written this way |
|-------|------|---------------------------|
| 1 | `import { useState } from 'react'` | Two strings of state (status and transcript) are all this app needs, so there's no Redux, Zustand or context. |
| 2 | `import { pipeline } from '@huggingface/transformers'` | Transformers.js is the one added dependency. It runs the real Whisper weights (converted to ONNX) in the browser using WebAssembly or WebGPU. It also handles audio decoding, resampling to 16 kHz, the log-mel spectrogram, tokenizing and decoding, which would otherwise be hundreds of lines. |
| 3 | `import './App.css'` | Plain CSS, two rules. No UI library is needed for one input and one paragraph. |
| 5 | `// ponytail: …` | Marks a deliberate shortcut and says when to fix it: move inference to a Web Worker if the page freezing during transcription becomes a problem. |
| 6 | `let transcriber` | A module-level cache. The model is created once per page load, not on every render or every file. |
| 7–8 | `getTranscriber = () => (transcriber ??= pipeline(...))` | Loads lazily. The ~40 MB download starts only when someone picks a file, so the page opens instantly. `??=` stores the *promise*, which means two quick uploads share one download instead of starting two. |
| 8 | `'Xenova/whisper-tiny.en'` | The smallest English-only Whisper (39M parameters). It's fast on a laptop CPU and good enough for clear speech. To trade speed for accuracy, change this string (see above). |
| 10 | `export default function App()` | One component. The app has one screen and one job, so there's nothing to split out. |
| 11–12 | `useState('')` ×2 | `text` holds the transcript. `status` holds the loading, transcribing or error message. An empty string means "show nothing", so no separate boolean flags are needed. |
| 14–16 | `const file = e.target.files[0]; if (!file) return` | Guards against the user opening the file picker and then cancelling. |
| 17 | `setText('')` | Clears the previous transcript so an old result never sits next to a new file. |
| 18–29 | `try { … } catch (err)` | Shows download or decode failures (offline, unsupported file) on the page instead of failing silently in the console. |
| 19–21 | `setStatus(...)` around `await getTranscriber()` | The first run can take a few seconds while the model downloads, so the user is told why nothing has happened yet. Then the status switches to "Transcribing…". |
| 22 | `URL.createObjectURL(file)` | Transformers.js accepts a URL and decodes it with the browser's own `AudioContext`. That gives us mp3, wav, m4a, ogg and more for free, with no manual decoding code. |
| 23 | `asr(url, { chunk_length_s: 30 })` | Whisper only sees 30 seconds of audio at a time. Chunking lets files of any length work instead of being cut off after 30 seconds. |
| 24 | `URL.revokeObjectURL(url)` | Frees the memory the browser holds for the file once decoding is done. |
| 25–26 | `setText(out.text); setStatus('')` | Shows the result and clears the progress message. |
| 36 | `<input type="file" accept="audio/*">` | The browser's native file picker. `accept` filters to audio files on desktop and mobile, so there's no dropzone library. |
| 37–38 | `{status && …}` / `{text && …}` | Renders only what exists, so empty paragraphs never take up space. |

`App.css`: `max-width` plus padding keeps the text readable and phone-friendly. `white-space: pre-wrap` keeps any line breaks Whisper puts in the transcript.

### Deliberately left out

- **Microphone recording.** A file picker covers the use case. Add `MediaRecorder` if you want live dictation.
- **Web Worker.** See the `ponytail:` comment on line 5.
- **A backend or the OpenAI API.** Running locally is free and private, and it works offline after the first load.

## Checkpoint 2: database and SQL script

Everything for CSE 111 Checkpoint 2 is in `checkpoint2/`

| File | What it is |
|------|------------|
| `Checkpoint2-dbase.sqlite3` | The SQLite database with all 10 tables and sample data |
| `Checkpoint2-script.sql` | 32 SQL statements (10 simple, 11 intermediate, 11 complex) |
| `schema.sql` | Creates the tables |
| `seed.sql` | Fills them with sample data (made up, not real restaurants or users) |

To run the script the same way it gets graded:

```
cd checkpoint2
sqlite3 Checkpoint2-dbase.sqlite3
.read Checkpoint2-script.sql
```

The script has inserts, updates and deletes so it changes the database. To get the original back:

```
rm Checkpoint2-dbase.sqlite3
sqlite3 Checkpoint2-dbase.sqlite3 < schema.sql
sqlite3 Checkpoint2-dbase.sqlite3 < seed.sql
```

The tables come from the relation spec in `docs/checkpoint1/`. Changes since Checkpoint 1 are listed at the top of the script

## History of Whisper

| Date | Milestone |
|------|-----------|
| Sep 2022 | OpenAI releases Whisper along with the paper *Robust Speech Recognition via Large-Scale Weak Supervision*. Code and weights are MIT-licensed. There are five sizes, from tiny (39M parameters) to large (1.55B). They were trained on 680,000 hours of weakly supervised multilingual audio from the web. |
| Dec 2022 | `large-v2` ships. It's the same architecture trained for more epochs with regularization, which gives better accuracy. |
| Mar 2023 | OpenAI launches the hosted Whisper API (`whisper-1`, based on large-v2). The open weights stay available. |
| 2023 | Community ports make Whisper run almost anywhere: `whisper.cpp` (C/C++, CPU and Apple Silicon), `faster-whisper` (CTranslate2), and Transformers.js (ONNX in the browser, which this app uses). |
| Nov 2023 | `large-v3` is released. It uses 128 mel bins, adds Cantonese, and was trained on 1M hours of weakly labeled audio plus 4M hours of pseudo-labeled audio. |
| Oct 2024 | `large-v3-turbo` is released. The decoder is pruned from 32 layers to 4, which makes it much faster with little loss in accuracy. |

## Project history

- **2026-09-24**: Scaffolded with `npm create vite@latest --template react`. Added `@huggingface/transformers` and a single-page file-upload transcriber in `src/App.jsx`.
- **2026-09-24**: Moved out of the `tpch` lab repo into its own repo, `foodFriend`. Added the line-by-line code walkthrough to this README.
- **2026-11-16**: Checkpoint 2. Added the SQLite schema, sample data, database file and the SQL script in `checkpoint2/`
