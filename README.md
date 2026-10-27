# caelestia-quickshell (personal fork)

A personal configuration fork of [midnight-shell](https://github.com/dim-ghub/midnight-shell)
with an integrated AI assistant sidebar featuring native Tavily web search, clipboard
image attachment, persistent chat history, and a visual Hyprland keybinds editor.

**Based on**: midnight-shell (fork lineage)
**Branch**: `feat/ai-sidebar-improvements`
**License**: GPL-3.0 (derivative of midnight-shell)

> [!NOTE]
> This repo tracks **only the user-local modifications**. It relies on a system-wide
> midnight-shell install at `/etc/xdg/quickshell/caelestia/` for shared components,
> services, utilities, and assets. See [Architecture](#architecture) below.

---

## Architecture

This config separates **shared system files** from **personal modifications** using
symlinks, following Quickshell's two-level config resolution:

```
/etc/xdg/quickshell/caelestia/          ← System-wide install (midnight-shell base)
  ├── modules/                          ← Full module library (281 files)
  ├── services/                         ← Service definitions (27 files)
  ├── components/                       ← Shared UI components (66 QML files)
  ├── utils/                            ← Utility scripts and helpers
  ├── assets/                           ← Media, fonts, wallpapers, sounds
  └── shell.qml                         ← System-wide entry point

~/.config/quickshell/caelestia/         ← Your personal config (this repo)
  ├── shell.qml                         ← Modified entry point (overrides system)
  ├── modules/                          ← Your modified + new modules (285 files)
  ├── scripts/                          ← Your scripts (7 AI scripts in scripts/ai/)
  ├── assets/        → symlink         ← Points to /etc/xdg/.../assets/
  ├── components/    → symlink         ← Points to /etc/xdg/.../components/
  ├── services/      → symlink         ← Points to /etc/xdg/.../services/
  └── utils/         → symlink         ← Points to /etc/xdg/.../utils/
```

**Quickshell resolves files top-to-bottom**: user config (`~/.config/...`) overrides
system-wide (`/etc/xdg/...`). Your `modules/`, `shell.qml`, and `scripts/` are tracked
in git and override the system versions. The `assets/`, `components/`, `services/`,
and `utils/` directories are symlinked to the system install — you don't need to
track them in git because they don't change.

---

## Prerequisites

- **Arch Linux** or **CachyOS** with **Quickshell** installed
- **caelestia-shell plugin** (the C++ plugin providing `Caelestia.Config`, `Caelestia` imports)
  - Install from [midnight-shell](https://github.com/dim-ghub/midnight-shell) or
    [caelestia-shell-aw](https://github.com/adiambassador/caelestia-shell-aw)
- **Hyprland** (window manager — the shell integrates with it via IPC)
- **Python 3** (for AI search scripts — stdlib only, no pip dependencies)
- **wl-paste** or **cliphist** (for clipboard image attachment)
- **Bash** (for `attach_clipboard.sh`)

### Installing Quickshell + Caelestia

```bash
# Install Quickshell (CachyOS / Arch)
pacman -S quickshell

# Or via AUR
yay -S quickshell-git

# The caelestia plugin is typically bundled with the shell binary
# or installed alongside it. Verify imports resolve:
#   Caelestia.Config  → provided by the plugin
#   qs.components     → provided by /etc/xdg/quickshell/caelestia/components/
```

---

## Installation

### Step 1: Install system-wide base

Clone midnight-shell (or aw) to the system-wide location:

```bash
sudo mkdir -p /etc/xdg/quickshell
sudo git clone https://github.com/dim-ghub/midnight-shell /etc/xdg/quickshell/caelestia
```

If using the aw fork:

```bash
sudo git clone https://github.com/adiambassador/caelestia-shell-aw /etc/xdg/quickshell/caelestia
```

### Step 2: Clone this repo to your user config

```bash
mkdir -p ~/.config/quickshell
git clone https://github.com/YOUR_USERNAME/caelestia-quickshell.git ~/.config/quickshell/caelestia
cd ~/.config/quickshell/caelestia
```

### Step 3: Run the setup script

```bash
chmod +x setup.sh
./setup.sh
```

The setup script will:
1. Verify `/etc/xdg/quickshell/caelestia/` exists
2. Create the four symlinks (`assets/`, `components/`, `services/`, `utils/`)
3. Report any issues

### Step 4: Configure Tavily API key (for AI web search)

```bash
# Option A: Create a config file
mkdir -p ~/.config/caelestia
cat > ~/.config/caelestia/shell.json << 'EOF'
{
    "ai": {
        "tavilyApiKey": "YOUR_TAVILY_API_KEY_HERE"
    }
}
EOF

# Option B: Set an environment variable
echo 'export TAVILY_API_KEY="your-key-here"' >> ~/.config/environment.d/envvars.conf

# Option C: Use the built-in fallback dev key (limited usage)
# The scripts have a fallback Tavily dev key, but it has rate limits
```

Get a Tavily API key at https://app.tavily.com.

---

## Key Features

### AI Assistant Sidebar

An integrated AI assistant accessible from the sidebar with:

| Shortcut | Action |
|---|---|
| **Ctrl+O** | Toggle expand (compact ↔ full width) |
| **Ctrl+P** | Pin sidebar (stay visible when unfocused) |
| **Ctrl+D** | Dismiss/close the sidebar |
| **Ctrl+V** | Attach clipboard image (screenshot paste) |
| **Enter** | Send message |
| **Shift+Enter** | Newline in input |
| **Tab** | Autocomplete `/command` if matches exist |
| **Esc** (while typing) | Cancel current AI request |

**AI backend architecture**:
- `scripts/ai/tavily_search.py` — Primary web search via Tavily API
- `scripts/ai/orion_search.py` — Alternative search with DuckDuckGo fallback
- `scripts/ai/image_to_base64.py` — Encodes clipboard images for inline display
- `scripts/ai/get_tavily_key.py` — Resolves API key from `shell.json` → env var → dev fallback
- `scripts/ai/load_chat_history.py` / `save_chat_history.py` — Persistent history at `~/.local/share/caelestia/ai/chats.json`
- `attach_clipboard.sh` — Grabs image from clipboard via `wl-paste` or `cliphist`

**Chat features**:
- Persistent history (sessions survive shell restarts)
- History grid view in the sidebar (click to restore, `×` to delete, "Clear All" button)
- Model/provider selector with grouped sections (expandable/collapseable)
- Thinking/reasoning block display (`MessageThinkBlock.qml`)
- File attachment preview with image thumbnails (`AttachedFileIndicator.qml`)
- Tool call support (Tavily search results displayed inline)

### Visual Hyprland Keybinds Editor

`modules/nexus/pages/hyprland/HyprKeybindsPage.qml` — A complete rewrite from midnight-shell's plain text display. This version:

- Displays keybinds **grouped by category** (Launcher & Shell, Workspaces, Windows, Media, etc.)
- Reads from **`~/.config/caelestia/hypr-vars.lua`** for your custom bindings
- Falls back to **`~/.config/hypr/variables.lua`** for Hyprland defaults
- Shows key hints (e.g., "hold + 1–0" for workspace groups)
- Clickable items with hover states and visual feedback

### Dock Infrastructure

Added to `shell.qml`:
- `Gate { id: dockGate }` — Conditional gate for dock visibility
- `Component { id: dockComponent }` — Lazy-loaded Dock component
- `Loader { active: dockGate.gateEnabled }` — Dynamically loads dock only when active

This means the dock module is **zero-cost** when not in use (not loaded into memory until the gate enables it).

### Service Initialization

`shell.qml` forces critical services to initialize at startup via property bindings:
```qml
property var _arpcInit: DiscordRPC
property var _gameModeInit: GameMode
property var _pipInit: PipManager
property var _systemTrayInit: SystemTray
```
This ensures services that midnight-shell might lazy-load are always available.

### Configuration Toasts

`ConfigToasts.qml` — Toast notifications when config files are loaded or saved (useful for debugging config changes).

### Performance Tuning

- `settings.watchFiles: false` — Disables Quickshell's file-watcher hot-reload (prevents restarts on every config edit during runtime)
- Dock loaded lazily via Gate/Loader (no overhead when dock is inactive)

---

## File Structure

```
~/.config/quickshell/caelestia/
├── shell.qml                    ← Entry point (modified from upstream)
├── README.md                    ← This file
├── LICENSE                      ← GPL-3.0
├── .gitignore
├── setup.sh                     ← Symlink setup script
├── modules/                     ← Your modified + new modules (285 files)
│   ├── sidebar/                 ← AI assistant sidebar (your main feature)
│   │   ├── AiAssistant.qml      ← Main AI sidebar (376+ lines added vs upstream)
│   │   ├── AttachedFileIndicator.qml  ← File attachment preview
│   │   └── aiChat/              ← AI chat subcomponents
│   │       ├── AiMessage.qml    ← Chat bubble UI
│   │       ├── AiMessageData.qml ← Data model (QtObject)
│   │       └── MessageThinkBlock.qml ← Reasoning display
│   ├── Shortcuts.qml            ← Custom keybinds (320 lines, your addition)
│   ├── BatteryMonitor.qml       ← Battery status (your addition)
│   ├── ConfigToasts.qml         ← Config change notifications (your addition)
│   ├── ServiceLoader.qml        ← Service init manager (your addition)
│   ├── IdleMonitors.qml         ← DPMS/idle control (your addition)
│   ├── nexus/pages/hyprland/HyprKeybindsPage.qml  ← Visual keybind editor (rewritten)
│   └── ...                      ← Rest inherited from midnight-shell (212 unchanged)
├── scripts/                     ← Your scripts
│   └── ai/                      ← AI backend scripts (7 files, your addition)
│       ├── tavily_search.py
│       ├── orion_search.py
│       ├── image_to_base64.py
│       ├── attach_clipboard.sh
│       ├── get_tavily_key.py
│       ├── load_chat_history.py
│       └── save_chat_history.py
├── assets/ → symlink to /etc/xdg/.../assets/
├── components/ → symlink to /etc/xdg/.../components/
├── services/ → symlink to /etc/xdg/.../services/
└── utils/ → symlink to /etc/xdg/.../utils/
```

### Testing Sandbox

`../dockprobe/` — A minimal test clone of this repo with a 359-byte debug `shell.qml`.
Used for quick QML loading verification without the full shell. Contains `console.warn`
debug statements. Safe to delete if not needed.

---

## Branch Strategy

- `main` — Baseline commit (`997fc329`), the midnight-shell tree before your modifications
- `feat/ai-sidebar-improvements` — Active development branch (current HEAD)

---

## Updating from Upstream

This repo has read-only remotes for all three upstreams:

```bash
# Fetch latest from midnight-shell
git fetch upstream-midnight

# See what changed
git log upstream-midnight/main..HEAD --oneline  # your commits
git log HEAD..upstream-midnight/main --oneline  # upstream changes

# To merge upstream changes (manual review recommended)
git diff upstream-midnight/main HEAD -- modules/  # see your changes
```

Since this repo has **no shared git history** with upstream (it was created fresh from midnight-shell's file tree), traditional `git merge` won't work cleanly. Instead:

1. Fetch upstream: `git fetch upstream-midnight`
2. Compare file trees: `git diff upstream-midnight/main HEAD -- modules/ shell.qml`
3. Manually merge changes by comparing modified files
4. Commit the merge

---

## Differences from Upstream

### vs midnight-shell (dim-ghub/midnight-shell)
- Stripped: `daemons/` directory (5 files), `plugin/` C++ source, `nix/`, `.github/` CI
- Stripped: dev scripts (qml-lint-conventions.py, trs-check.py, trs.fish, replace_xhr.py, replace_footer.py)
- Stripped: `UnmaintainedNotice.qml` (234 lines)
- Added: AI assistant sidebar with Tavily web search (11 new module files + 7 scripts)
- Modified: `shell.qml` (removed daemons import, added ServiceLoader, dock Gate/Loader, ConfigToasts, performance tuning)
- Modified: `HyprKeybindsPage.qml` (rewrote as visual keybind editor with config file support)

See [Three-Way Comparison](docs/three-way-comparison.md) for full diff stats.

### vs caelestia-shell-aw (adiambassador/caelestia-shell-aw)
- Both forked midnight-shell and stripped `daemons/`
- You stripped MORE: `plugin/`, `nix/`, `.github/`, dev scripts, `components/` (via symlinks)
- aw kept the full plugin build system; you rely on the precompiled system install
- You added AI sidebar + visual keybinds editor that aw doesn't have

### vs caelestia-dots/caelestia (upstream-main)
- **Completely unrelated project** — that's the Hyprland dotfiles repo (hypr/, nvim/, fish/)
- Your `kelly26ici/caelestia` GitHub fork points to THAT repo, not this shell config
- This shell config has never been pushed to GitHub

---

## Credits

- **midnight-shell** — [dim-ghub/midnight-shell](https://github.com/dim-ghub/midnight-shell) (GPL-3.0)
- **caelestia-shell** — [caelestia-dots/shell](https://github.com/caelestia-dots/shell) (original, GPL-3.0)
- **caelestia-shell-aw** — [adiambassador/caelestia-shell-aw](https://github.com/adiambassador/caelestia-shell-aw) (GPL-3.0 fork)

This is a derivative work. See [LICENSE](LICENSE) for the full GPL-3.0 text.
