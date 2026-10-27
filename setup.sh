#!/usr/bin/env bash
# setup.sh — Configure symlinks for caelestia-quickshell personal config
#
# This script links shared directories (assets, components, services, utils)
# from the system-wide midnight-shell install to this user config repo.
# Run after cloning this repo to ~/.config/quickshell/caelestia/

set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/caelestia"
SYSTEM_DIR="/etc/xdg/quickshell/caelestia"
SYMLINK_DIRS=("assets" "components" "services" "utils")

# --- Helpers ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# --- Checks ---
if [ ! -d "$SYSTEM_DIR" ]; then
    error "System-wide caelestia shell not found at: $SYSTEM_DIR"
    echo ""
    echo "Install midnight-shell first:"
    echo "  sudo mkdir -p /etc/xdg/quickshell"
    echo "  sudo git clone https://github.com/dim-ghub/midnight-shell /etc/xdg/quickshell/caelestia"
    echo ""
    echo "Or the aw fork:"
    echo "  sudo git clone https://github.com/adiambassador/caelestia-shell-aw /etc/xdg/quickshell/caelestia"
    exit 1
fi

if [ ! -f "$SYSTEM_DIR/shell.qml" ]; then
    error "System-wide shell.qml missing at: $SYSTEM_DIR/shell.qml"
    exit 1
fi

if [ ! -d "$CONFIG_DIR/modules" ]; then
    error "This script must be run from the config repo root:"
    echo "  cd $CONFIG_DIR"
    echo "  ./setup.sh"
    exit 1
fi

info "System-wide shell: $SYSTEM_DIR"
info "User config:       $CONFIG_DIR"
echo ""

# --- Create symlinks ---
all_ok=true

for dir in "${SYMLINK_DIRS[@]}"; do
    target="$SYSTEM_DIR/$dir"
    link="$CONFIG_DIR/$dir"

    if [ ! -d "$target" ]; then
        warn "System dir missing: $target — skipping $dir"
        continue
    fi

    if [ -L "$link" ]; then
        current_target=$(readlink -f "$link")
        if [ "$current_target" = "$(readlink -f "$target")" ]; then
            info "✓ $dir already linked correctly"
        else
            warn "$dir points to '$current_target', removing and re-linking"
            rm -f "$link"
            ln -s "$target" "$link"
            info "✓ $dir re-linked to $target"
        fi
    elif [ -d "$link" ]; then
        error "$dir exists as a real directory — not a symlink"
        error "Please remove or back it up first, then re-run setup.sh"
        all_ok=false
    else
        ln -s "$target" "$link"
        info "✓ $dir → $target"
    fi
done

echo ""

# --- Verify shell.qml is present ---
if [ -f "$CONFIG_DIR/shell.qml" ]; then
    info "✓ shell.qml present (user override of system entry point)"
else
    warn "shell.qml missing — system-wide entry point will be used"
fi

# --- Summary ---
if [ "$all_ok" = true ]; then
    echo ""
    info "Setup complete! Your personal config is linked to the system-wide install."
    echo ""
    echo "Next steps:"
    echo "  1. Configure Tavily API key: ~/.config/caelestia/shell.json"
    echo "  2. Restart Quickshell:     pkill quickshell; quickshell"
    echo "  3. Open AI sidebar:        Check your Hyprland keybind for AiAssistant"
    echo ""
    echo "  Tip: Use dockprobe/shell.qml for quick load testing without full shell"
else
    echo ""
    error "Setup incomplete. Fix the issues above and re-run setup.sh"
    exit 1
fi
