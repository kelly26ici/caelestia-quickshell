#!/usr/bin/env python3
import json
import os

conf_path = os.path.expanduser("~/.config/caelestia/shell.json")
try:
    with open(conf_path, "r", encoding="utf-8") as f:
        data = json.load(f)
        key = data.get("ai", {}).get("tavilyApiKey", "")
        if key:
            print(key)
            exit(0)
except Exception:
    pass

# Fallback: check environment or default key
env_key = os.environ.get("TAVILY_API_KEY", "")
if env_key:
    print(env_key)
    exit(0)

# Known active default fallback
print("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")
