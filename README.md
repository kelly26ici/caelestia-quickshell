# kelly26ici-caelestia

Personal Quickshell config fork of midnight-shell.

## Added features

- AI assistant sidebar with Tavily web search, clipboard image attachment, persistent chat history
- Visual Hyprland keybinds editor (replaces midnight-shell's plain text display)
- Dock infrastructure with lazy-loaded Gate/Loader/Component pattern
- `ServiceLoader.qml` for forced service init at startup
- `ConfigToasts.qml` for config change notifications
- 7 stdlib-only AI scripts in `scripts/ai/` (no pip dependencies)
- `setup.sh` for automated symlink creation to `/etc/xdg/quickshell/caelestia/`

## Setup

```fish
./setup.sh
```

## Credits

- [midnight-shell](https://github.com/dim-ghub/midnight-shell) (GPL-3.0)
- [caelestia-shell-aw](https://github.com/adiambassador/caelestia-shell-aw) (GPL-3.0)
- Original [caelestia-shell](https://github.com/caelestia-dots/shell) (GPL-3.0)

Derivative work. See LICENSE for full GPL-3.0 text.
