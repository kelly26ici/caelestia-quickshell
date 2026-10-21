#!/usr/bin/env python3
import sys
import json
import os

path = os.path.expanduser("~/.local/share/caelestia/ai/chats.json")
os.makedirs(os.path.dirname(path), exist_ok=True)

try:
    content = sys.stdin.read()
    if content.strip():
        data = json.loads(content)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
except Exception as e:
    sys.stderr.write(f"Error saving chat history: {e}\n")
    sys.exit(1)
