#!/usr/bin/env bash
# record-meeting.sh — Record mic + system audio for meeting transcription
#
# Usage: record-meeting.sh [check|start|stop|status]
#
# Config: ~/.config/meeting-transcriber/config.py (INBOX_DIR)

set -euo pipefail

# ── Load config ──────────────────────────────────────────────────────────────
CONFIG_FILE="${HOME}/.config/meeting-transcriber/config.py"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config not found: $CONFIG_FILE"
    echo "Creating from template..."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cp "${TEMPLATE_DIR}/config.template.py" "$CONFIG_FILE"
    echo "Edit $CONFIG_FILE and run again."
    exit 1
fi

INBOX_DIR=$(python3 -c "
import sys; sys.path.insert(0, '$(dirname "$CONFIG_FILE")')
exec(open('$CONFIG_FILE').read())
print(INBOX_DIR)
" 2>/dev/null | tail -1)
INBOX_DIR="${INBOX_DIR/#\~/$HOME}"

MONITOR_SOURCE_OVERRIDE=$(python3 -c "
import sys; sys.path.insert(0, '$(dirname "$CONFIG_FILE")')
exec(open('$CONFIG_FILE').read())
print(MONITOR_SOURCE if 'MONITOR_SOURCE' in dir() and MONITOR_SOURCE else '')
" 2>/dev/null | tail -1)

# ── Constants ────────────────────────────────────────────────────────────────
PID_FILE="/tmp/meeting-record.pid"
CMD="${1:-check}"

# ── Helpers ──────────────────────────────────────────────────────────────────
detect_mic() {
    pactl list sources short 2>/dev/null \
        | grep -v monitor \
        | awk '{print $2}' \
        | head -1
}

detect_monitor() {
    if [[ -n "${MONITOR_SOURCE_OVERRIDE:-}" ]]; then
        echo "$MONITOR_SOURCE_OVERRIDE"
    else
        pactl list sources short 2>/dev/null \
            | grep monitor \
            | awk '{print $2}' \
            | head -1
    fi
}

test_level() {
    local src="$1"
    ffmpeg -f pulse -i "$src" -t 2 \
        -af "volumedetect" -f null /dev/null 2>&1 \
        | grep "mean_volume" | awk '{print $5}' || echo "unknown"
}

# ── Commands ─────────────────────────────────────────────────────────────────
cmd_check() {
    echo "=== Audio Source Check ==="
    local ok=true

    MIC=$(detect_mic)
    if [[ -z "$MIC" ]]; then
        echo "MIC:     NOT FOUND"
        ok=false
    else
        echo "MIC:     $MIC"
        echo -n "         Testing 2s — speak now... "
        LEVEL=$(test_level "$MIC")
        echo "mean_volume: ${LEVEL} dB"
    fi

    echo ""

    MONITOR=$(detect_monitor)
    if [[ -z "$MONITOR" ]]; then
        echo "MONITOR: NOT FOUND"
        ok=false
    else
        echo "MONITOR: $MONITOR"
        echo -n "         Testing 2s — play some audio... "
        LEVEL=$(test_level "$MONITOR")
        echo "mean_volume: ${LEVEL} dB"
        if [[ "$LEVEL" == "-91"* ]]; then
            echo "         NOTE: silent now — will record once meeting audio plays"
        fi
    fi

    echo ""
    if $ok; then
        echo "STATUS: ready"
        echo "INBOX:  $INBOX_DIR"
    else
        echo "STATUS: cannot record — missing sources"
        echo ""
        echo "Available sources:"
        pactl list sources short
        exit 1
    fi
}

cmd_start() {
    if [[ -f "$PID_FILE" ]]; then
        PID=$(cut -d: -f1 "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "Already recording (PID $PID)"
            exit 1
        fi
        rm -f "$PID_FILE"
    fi

    MIC=$(detect_mic)
    MONITOR=$(detect_monitor)

    if [[ -z "$MIC" || -z "$MONITOR" ]]; then
        echo "ERROR: audio sources not found. Run 'check' first."
        exit 1
    fi

    mkdir -p "$INBOX_DIR"
    OUTPUT="${INBOX_DIR}/$(date +%Y-%m-%d_%H-%M-%S).wav"

    ffmpeg \
        -f pulse -i "$MIC" \
        -f pulse -i "$MONITOR" \
        -filter_complex "[0:a][1:a]amix=inputs=2:duration=longest:weights=1 1" \
        -ar 16000 -ac 1 -c:a pcm_s16le \
        "$OUTPUT" \
        -loglevel quiet \
        </dev/null >/dev/null 2>&1 &

    FFMPEG_PID=$!
    echo "${FFMPEG_PID}:${OUTPUT}" > "$PID_FILE"

    echo "Recording started (PID $FFMPEG_PID)"
    echo "Output: $OUTPUT"
}

cmd_stop() {
    if [[ ! -f "$PID_FILE" ]]; then
        echo "No recording in progress"
        exit 1
    fi

    INFO=$(cat "$PID_FILE")
    PID="${INFO%%:*}"
    OUTPUT="${INFO##*:}"

    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        sleep 0.5
        rm -f "$PID_FILE"
        echo "Recording stopped"
        echo "File: $OUTPUT"
        echo "Size: $(du -h "$OUTPUT" 2>/dev/null | cut -f1 || echo 'unknown')"
    else
        rm -f "$PID_FILE"
        echo "Process not running — recording may have ended"
        echo "File: $OUTPUT"
    fi
}

cmd_status() {
    if [[ ! -f "$PID_FILE" ]]; then
        echo "Not recording"
        exit 0
    fi

    INFO=$(cat "$PID_FILE")
    PID="${INFO%%:*}"
    OUTPUT="${INFO##*:}"

    if kill -0 "$PID" 2>/dev/null; then
        echo "Recording (PID $PID)"
        echo "File: $OUTPUT"
        echo "Size: $(du -h "$OUTPUT" 2>/dev/null | cut -f1 || echo 'growing...')"
    else
        rm -f "$PID_FILE"
        echo "Not recording (process ended)"
    fi
}

# ── Dispatch ─────────────────────────────────────────────────────────────────
case "$CMD" in
    check)  cmd_check  ;;
    start)  cmd_start  ;;
    stop)   cmd_stop   ;;
    status) cmd_status ;;
    *)
        echo "Usage: $0 [check|start|stop|status]"
        exit 1
        ;;
esac
