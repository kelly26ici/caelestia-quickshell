#!/usr/bin/env bash
mkdir -p /tmp/caelestia-ai-attachments
out="/tmp/caelestia-ai-attachments/clip_$(date +%s%N).png"

# Try wl-paste image first
if wl-paste -t image/png > "$out" 2>/dev/null; then
    if [ -s "$out" ]; then
        echo "$out"
        exit 0
    fi
fi

# Try cliphist decode
first_entry=$(cliphist list 2>/dev/null | head -n 1)
if echo "$first_entry" | grep -qi "binary data"; then
    echo "$first_entry" | cliphist decode > "$out" 2>/dev/null
    if [ -s "$out" ]; then
        echo "$out"
        exit 0
    fi
fi

rm -f "$out"
exit 1
