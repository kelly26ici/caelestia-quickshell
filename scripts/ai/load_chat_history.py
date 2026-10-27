#!/usr/bin/env python3
import json
import os

path = os.path.expanduser("~/.local/share/caelestia/ai/chats.json")
if os.path.exists(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            print(f.read())
            exit(0)
    except Exception:
        pass
print("[]")
