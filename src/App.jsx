import { useState } from 'react'
import { pipeline } from '@huggingface/transformers'
import './App.css'

// ponytail: model loads lazily on first use and runs on the main thread; move to a Web Worker if the UI freeze bothers you
let transcriber
const getTranscriber = () =>
  (transcriber ??= pipeline('automatic-speech-recognition', 'Xenova/whisper-tiny.en'))

export default function App() {
  const [text, setText] = useState('')
  const [status, setStatus] = useState('')

  async function onFile(e) {
    const file = e.target.files[0]
    if (!file) return
    setText('')
    try {
      setStatus('Loading Whisper (first run downloads ~40 MB)…')
      const asr = await getTranscriber()
      setStatus('Transcribing…')
      const url = URL.createObjectURL(file)
      const out = await asr(url, { chunk_length_s: 30 })
      URL.revokeObjectURL(url)
      setText(out.text)
      setStatus('')
    } catch (err) {
      setStatus(`Error: ${err.message}`)
    }
  }

  return (
    <main>
      <h1>Whisper in React</h1>
      <p>Pick an audio file. OpenAI's open-source Whisper runs in your browser, so your audio stays on your machine.</p>
      <input type="file" accept="audio/*" onChange={onFile} />
      {status && <p>{status}</p>}
      {text && <p className="transcript">{text}</p>}
    </main>
  )
}
