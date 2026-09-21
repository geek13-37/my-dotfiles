#!/usr/bin/env bash
#
# Usage: ./install.sh [--no-packages]
#   --no-packages   skip pacman/AUR install, only (re)link configs
#
# niri, noctalia and fish are assumed preinstalled (CachyOS default) and are
# not installed here - only their configs get linked.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
SKIP_PACKAGES=0

for arg in "$@"; do
    case "$arg" in
        --no-packages) SKIP_PACKAGES=1 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

CONFIGS=(
    niri
    noctalia
    ghostty
    fish
    fastfetch
    mimeapps.list
)

if [ "$SKIP_PACKAGES" -eq 0 ]; then
    if ! command -v pacman >/dev/null 2>&1; then
        echo "==> pacman not found, skipping package install (use --no-packages to silence this)"
    else
        echo "==> Installing packages"
        mapfile -t PACKAGES < <(grep -vE '^\s*#|^\s*$' "$DOTFILES_DIR/packages.txt")
        sudo pacman -S --needed "${PACKAGES[@]}"

        mapfile -t AUR_PACKAGES < <(grep -vE '^\s*#|^\s*$' "$DOTFILES_DIR/packages-aur.txt")
        if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
            if command -v yay >/dev/null 2>&1; then
                echo "==> Installing AUR packages"
                yay -S --needed "${AUR_PACKAGES[@]}"
            elif command -v paru >/dev/null 2>&1; then
                echo "==> Installing AUR packages"
                paru -S --needed "${AUR_PACKAGES[@]}"
            else
                echo "==> No AUR helper (yay/paru) found, skipping AUR packages (${AUR_PACKAGES[*]}) - install one and rerun"
            fi
        fi
    fi
else
    echo "==> Skipping package install (--no-packages)"
fi

# Telegram, Happ and Spotify are only installed above - their own configs are
# intentionally NOT managed/symlinked by this repo.

echo "==> Linking configs from $DOTFILES_DIR"

mkdir -p "$CONFIG_DIR"

link_config() {
    local name="$1"

    if [ -e "$CONFIG_DIR/$name" ] && [ ! -L "$CONFIG_DIR/$name" ]; then
        echo "Backing up existing $name"
        mv "$CONFIG_DIR/$name" "$CONFIG_DIR/${name}.backup"
    fi

    ln -sfn "$DOTFILES_DIR/config/$name" "$CONFIG_DIR/$name"

    echo "Linked $name"
}

for name in "${CONFIGS[@]}"; do
    link_config "$name"
done

if command -v docker >/dev/null 2>&1 && command -v systemctl >/dev/null 2>&1; then
    echo "==> Enabling docker"
    sudo systemctl enable --now docker.service

    if ! groups "$USER" | grep -qw docker; then
        sudo usermod -aG docker "$USER"
        echo "Added $USER to the docker group (log out and back in for it to take effect)"
    fi
fi

if command -v sddm >/dev/null 2>&1 || [ -d /etc/sddm.conf.d ] || pacman -Qi sddm >/dev/null 2>&1; then
    echo "==> Installing caelestia-sddm theme (minimalistV2, Atuel palette)"

    sudo rm -rf /usr/share/sddm/themes/caelestia
    sudo mkdir -p /usr/share/sddm/themes/caelestia
    sudo cp -r "$DOTFILES_DIR/config/sddm/caelestia-theme/." /usr/share/sddm/themes/caelestia/
    sudo find /usr/share/sddm/themes/caelestia -type d -exec chmod 755 {} +
    sudo find /usr/share/sddm/themes/caelestia -type f -exec chmod 644 {} +
    echo "Installed caelestia theme to /usr/share/sddm/themes/caelestia"

    sudo mkdir -p /etc/sddm.conf.d
    sudo ln -sfn "$DOTFILES_DIR/config/sddm/theme.conf" /etc/sddm.conf.d/theme.conf
    echo "Linked sddm theme.conf"

    mkdir -p "$HOME/.config/caelestia/templates"
    ln -sfn "$DOTFILES_DIR/config/caelestia/templates/sddm-theme.conf" "$HOME/.config/caelestia/templates/sddm-theme.conf"

    # /etc/sddm.conf takes precedence over /etc/sddm.conf.d/*, so a leftover
    # Current= from a previously installed theme there would silently win.
    if [ -f /etc/sddm.conf ] && grep -qE '^Current=' /etc/sddm.conf; then
        echo "Removing conflicting Current= line from /etc/sddm.conf (leftover from another theme)"
        sudo cp /etc/sddm.conf /etc/sddm.conf.backup
        sudo sed -i '/^Current=/d' /etc/sddm.conf
    fi

    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl enable sddm.service >/dev/null 2>&1 || true
    fi
else
    echo "==> sddm not installed, skipping theme setup"
fi

echo "==> Linking noctalia state (bar layout, enabled plugins)"

STATE_DIR="$HOME/.local/state"
NOCTALIA_STATE_REPO="state/noctalia/settings.toml"
NOCTALIA_STATE="$STATE_DIR/noctalia/settings.toml"

mkdir -p "$STATE_DIR/noctalia"
if [ -e "$NOCTALIA_STATE" ] && [ ! -L "$NOCTALIA_STATE" ]; then
    echo "Backing up existing noctalia settings.toml"
    mv "$NOCTALIA_STATE" "$STATE_DIR/noctalia/settings.toml.backup"
fi
ln -sfn "$DOTFILES_DIR/$NOCTALIA_STATE_REPO" "$NOCTALIA_STATE"
echo "Linked noctalia/settings.toml"

echo "==> Linking local-path noctalia plugin (happ-control)"
# Everything else in settings.toml's [plugins] enabled list is a git/community
# plugin - Noctalia fetches those itself on startup. This one is sourced as a
# local path, so it needs to physically exist on disk.
mkdir -p "$HOME/Plugins"
if [ -e "$HOME/Plugins/happ-control" ] && [ ! -L "$HOME/Plugins/happ-control" ]; then
    echo "Backing up existing Plugins/happ-control"
    mv "$HOME/Plugins/happ-control" "$HOME/Plugins/happ-control.backup"
fi
ln -sfn "$DOTFILES_DIR/plugins/happ-control" "$HOME/Plugins/happ-control"

echo "==> Linking wallpaper"
mkdir -p "$HOME/Pictures"
if [ -e "$HOME/Pictures/wallhaven-yqkj3l.png" ] && [ ! -L "$HOME/Pictures/wallhaven-yqkj3l.png" ]; then
    echo "Backing up existing Pictures/wallhaven-yqkj3l.png"
    mv "$HOME/Pictures/wallhaven-yqkj3l.png" "$HOME/Pictures/wallhaven-yqkj3l.png.backup"
fi
ln -sfn "$DOTFILES_DIR/wallpapers/wallhaven-yqkj3l.png" "$HOME/Pictures/wallhaven-yqkj3l.png"

if command -v fish >/dev/null 2>&1 && command -v fisher >/dev/null 2>&1; then
    echo "==> Installing fish plugins (fisher)"
    fish -c "fisher update"
fi

echo
echo "Done! Log out and pick niri at the login screen (or run 'niri' from a TTY)."
