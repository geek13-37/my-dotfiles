#!/usr/bin/env bash
# Dotfiles installer for CachyOS (niri + noctalia + fish already present).
# Installs the remaining packages and symlinks every managed config into place.
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# 1. Packages
# ---------------------------------------------------------------------------
# niri, noctalia, fish are preinstalled on this system - not touched here.
PACMAN_PKGS=(ghostty telegram-desktop spotify-launcher)
AUR_PKGS=(happ)

if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman not found - this installer targets Arch/CachyOS. Skipping package install."
else
    log "Installing pacman packages: ${PACMAN_PKGS[*]}"
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

    AUR_HELPER=""
    if command -v yay >/dev/null 2>&1; then
        AUR_HELPER=yay
    elif command -v paru >/dev/null 2>&1; then
        AUR_HELPER=paru
    fi

    if [ -n "$AUR_HELPER" ]; then
        log "Installing AUR packages with $AUR_HELPER: ${AUR_PKGS[*]}"
        "$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}"
    else
        warn "No AUR helper (yay/paru) found - install manually: ${AUR_PKGS[*]}"
    fi
fi

# Note: Telegram, Happ and Spotify are only installed above - their configs
# are intentionally NOT managed/symlinked by this repo.

# ---------------------------------------------------------------------------
# 2. Symlink helpers
# ---------------------------------------------------------------------------
backup_suffix=".bak.$(date +%Y%m%d%H%M%S)"

# Symlink a path owned by the current user.
link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname -- "$dst")"

    if [ -L "$dst" ] && [ "$(readlink -- "$dst")" = "$src" ]; then
        log "ok:      $dst"
        return
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv -- "$dst" "$dst$backup_suffix"
        warn "backed up existing $dst -> $dst$backup_suffix"
    fi

    ln -s -- "$src" "$dst"
    log "linked:  $dst -> $src"
}

# Symlink a path that requires root (under /etc or /usr).
link_sudo() {
    local src="$1" dst="$2"
    sudo mkdir -p "$(dirname -- "$dst")"

    if sudo test -L "$dst" && [ "$(sudo readlink -- "$dst")" = "$src" ]; then
        log "ok:      $dst"
        return
    fi

    if sudo test -e "$dst" || sudo test -L "$dst"; then
        sudo mv -- "$dst" "$dst$backup_suffix"
        warn "backed up existing $dst -> $dst$backup_suffix"
    fi

    sudo ln -s -- "$src" "$dst"
    log "linked:  $dst -> $src (root)"
}

# ---------------------------------------------------------------------------
# 3. Niri
# ---------------------------------------------------------------------------
link "$DOTFILES_DIR/config/niri" "$HOME/.config/niri"

# ---------------------------------------------------------------------------
# 3b. Fish
# ---------------------------------------------------------------------------
link "$DOTFILES_DIR/config/fish" "$HOME/.config/fish"

# ---------------------------------------------------------------------------
# 4. Noctalia (settings + bar live under ~/.local/state/noctalia)
# ---------------------------------------------------------------------------
link "$DOTFILES_DIR/config/noctalia/settings.toml" "$HOME/.local/state/noctalia/settings.toml"

# Local-path noctalia plugin (git/community plugins are pulled by Noctalia
# itself from the `plugins.enabled` list in settings.toml - only this one,
# sourced as a local path, needs to physically exist on disk).
link "$DOTFILES_DIR/plugins/happ-control" "$HOME/Plugins/happ-control"

# ---------------------------------------------------------------------------
# 5. Ghostty
# ---------------------------------------------------------------------------
link "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"

# ---------------------------------------------------------------------------
# 6. SDDM (caelestia theme + config)
# ---------------------------------------------------------------------------
link_sudo "$DOTFILES_DIR/config/sddm/caelestia-theme" "/usr/share/sddm/themes/caelestia"
link_sudo "$DOTFILES_DIR/config/sddm/sddm.conf.d-theme.conf" "/etc/sddm.conf.d/theme.conf"
link "$DOTFILES_DIR/config/caelestia/templates/sddm-theme.conf" "$HOME/.config/caelestia/templates/sddm-theme.conf"

# ---------------------------------------------------------------------------
# 7. Wallpaper
# ---------------------------------------------------------------------------
link "$DOTFILES_DIR/wallpapers/wallhaven-yqkj3l.png" "$HOME/Pictures/wallhaven-yqkj3l.png"

log "Done. Log out / restart niri and sddm for everything to take effect."
