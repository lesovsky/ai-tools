---
name: lead-transcribe-meetings
description: |
  Records meeting audio (mic + system loopback) and processes recordings:
  transcribes with faster-whisper, generates Russian summary, saves to Obsidian.

  Use when: "запиши встречу", "начни запись", "record meeting", "stop recording",
  "останови запись", "обработай записи", "транскрибируй встречу",
  "/record-meeting", "/transcribe-meetings"
---

# Meeting Transcriber

Scripts are in the `scripts/` subdirectory of this SKILL.md's location.
Resolve SKILL_DIR from the path where this file was loaded, then use `{SKILL_DIR}/scripts/`.

User config: `~/.config/meeting-transcriber/config.py` (default location, set up by the user).
Contains: INBOX_DIR, PROCESSED_DIR, OBSIDIAN_DIR, WHISPER_MODEL, LANGUAGE.
Read it at the start to know actual paths before any step.

---

## Phase 1: Recording

Run `{SKILL_DIR}/scripts/record-meeting.sh status` to determine if recording is already active.

### Start recording

1. Run: `{SKILL_DIR}/scripts/record-meeting.sh check`
   Show detected mic and monitor sources with signal levels.

2. If any source is missing — stop. Show available sources:
   ```bash
   pactl list sources short
   ```
   Ask the user to identify the correct source names.

3. Both sources found → ask: "Источники найдены. Начинаем запись?"

4. On confirmation: `{SKILL_DIR}/scripts/record-meeting.sh start`

5. Report output file path. Tell the user:
   "Запись идёт. Когда встреча закончится — скажи 'стоп' или запусти `/record-meeting` снова."

**Checkpoint:** `record-meeting.sh status` confirms recording is active and reports the output file path.

### Stop recording

1. Run: `{SKILL_DIR}/scripts/record-meeting.sh stop`
2. Report file path and size.
3. Suggest: "Запись сохранена. Запусти `/transcribe-meetings` для обработки."

---

## Phase 2: Processing

### Dependency check

```bash
python3 -c "import faster_whisper" 2>/dev/null || echo "MISSING: pip install faster-whisper"
which ffmpeg 2>/dev/null || echo "MISSING: ffmpeg"
```

Missing dependency → explain what to install and stop.

### Scan inbox

Read INBOX_DIR from config. List audio/video files, excluding `processed/` subdirectory.
Supported: `.wav .mp3 .m4a .flac .ogg .mp4 .mkv .webm`

No files → tell the user and stop.
Files found → show list, ask: "Найдено N файл(ов). Обрабатываем?"

**Checkpoint:** At least one unprocessed file confirmed before proceeding.

### Process each file

**1. Prepare audio**

If video (`.mp4 .mkv .webm`): extract to temp:
```bash
ffmpeg -i "INPUT" -vn -ar 16000 -ac 1 -c:a pcm_s16le /tmp/meeting_audio.wav -y
```
If audio: use directly (convert to 16kHz WAV if not already).

**2. Transcribe**

```bash
python3 {SKILL_DIR}/scripts/transcribe.py /tmp/meeting_audio.wav
```

Read stdout as the transcript text. Progress goes to stderr.

**3. Generate summary**

Analyse the transcript and write a Markdown summary in Russian:

```markdown
## Саммари встречи — DD месяц YYYY

**Участники:** (если можно определить из контекста)
**Длительность:** X минут
**Тема:** (выведи из содержания)

---

### Контекст

(1–2 абзаца: что обсуждали и зачем)

### Ключевые решения

- ...

### Технические детали

(если есть: архитектурные решения, подходы к реализации)

### Action items

| Кто | Что | Когда |
|-----|-----|-------|
| ... | ... | ...   |
```

Omit sections that have no content (e.g. no action items → no table).

**4. Save to Obsidian**

Read OBSIDIAN_DIR from config.
- Month subdir: `YYYY-MM/` — create if missing
- Filename: `YYYY-MM-DD_HH-MM.md` (parse timestamp from recording filename)
- Write the summary

**5. Save transcript text**

Save the raw transcript text to PROCESSED_DIR as `YYYY-MM-DD_HH-MM.txt` (same timestamp as the recording).

**6. Move original**

Move source file to PROCESSED_DIR (from config). Create directory if missing.

**Checkpoint:** Obsidian `.md` file exists at the expected path, transcript `.txt` and original audio file are present in PROCESSED_DIR.

### Report

```
Обработано: N файл(ов)
Сохранено:
  - <OBSIDIAN_DIR>/YYYY-MM/YYYY-MM-DD_HH-MM.md
  - <PROCESSED_DIR>/YYYY-MM-DD_HH-MM.txt  (транскрипция)
Оригиналы → <PROCESSED_DIR>/
```

---

## Self-Verification

Before saving:
- [ ] All summary sections are filled or intentionally omitted
- [ ] Action items table has at least one row (or section is omitted)
- [ ] Obsidian path uses correct month subdir derived from OBSIDIAN_DIR
- [ ] Transcript `.txt` is saved to PROCESSED_DIR
- [ ] Original file will be moved to PROCESSED_DIR, not deleted
