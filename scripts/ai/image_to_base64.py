#!/usr/bin/env python3
import sys
import base64
import os

if len(sys.argv) < 2:
    sys.exit(1)

path = sys.argv[1]
if not os.path.exists(path):
    sys.exit(1)

ext = os.path.splitext(path)[1].lower().replace(".", "")
if ext == "jpg": ext = "jpeg"
if ext not in ["png", "jpeg", "webp", "gif"]:
    ext = "png"

with open(path, "rb") as f:
    encoded = base64.b64encode(f.read()).decode("utf-8")

print(f"data:image/{ext};base64,{encoded}")
