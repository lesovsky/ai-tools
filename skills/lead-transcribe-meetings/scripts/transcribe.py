#!/usr/bin/env python3
"""Transcribe audio file using faster-whisper.

Usage: transcribe.py <audio_file> [output_file]

Config: ~/.config/meeting-transcriber/config.py
Output: transcript text to stdout (or output_file if provided).
Progress is printed to stderr.
"""

import sys
import os
from pathlib import Path

# ── Load config ───────────────────────────────────────────────────────────────
CONFIG_FILE = Path.home() / ".config" / "meeting-transcriber" / "config.py"
TEMPLATE_FILE = Path(__file__).parent / "config.template.py"

if not CONFIG_FILE.exists():
    print(f"Config not found: {CONFIG_FILE}", file=sys.stderr)
    print(f"Creating from template...", file=sys.stderr)
    CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    CONFIG_FILE.write_text(TEMPLATE_FILE.read_text())
    print(f"Edit {CONFIG_FILE} and run again.", file=sys.stderr)
    sys.exit(1)

_cfg: dict = {}
exec(CONFIG_FILE.read_text(), _cfg)
WHISPER_MODEL: str = _cfg.get("WHISPER_MODEL", "medium")
LANGUAGE: str = _cfg.get("LANGUAGE", "ru")


# ── Transcribe ────────────────────────────────────────────────────────────────
def transcribe(audio_path: str) -> str:
    from faster_whisper import WhisperModel

    print(f"Loading model: {WHISPER_MODEL}", file=sys.stderr)
    model = WhisperModel(WHISPER_MODEL, device="cpu", compute_type="int8")

    print(f"Transcribing: {audio_path}", file=sys.stderr)
    segments, info = model.transcribe(audio_path, language=LANGUAGE, beam_size=5)

    print(f"Language: {info.language} ({info.language_probability:.2f})", file=sys.stderr)

    lines = []
    for seg in segments:
        text = seg.text.strip()
        print(f"[{seg.start:.1f}s] {text}", file=sys.stderr)
        lines.append(text)

    return "\n".join(lines)


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <audio_file> [output_file]", file=sys.stderr)
        sys.exit(1)

    audio_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    if not Path(audio_file).exists():
        print(f"ERROR: file not found: {audio_file}", file=sys.stderr)
        sys.exit(1)

    transcript = transcribe(audio_file)

    if output_file:
        Path(output_file).write_text(transcript, encoding="utf-8")
        print(f"Saved: {output_file}", file=sys.stderr)
    else:
        print(transcript)
