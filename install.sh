#!/usr/bin/env bash
#
# Bootstraps a fresh Arch Linux install (e.g. right after archinstall) into
# this desktop: Hyprland + Noctalia, SDDM, apps, dev tools, dotfiles.
# Safe to rerun: everything is --needed / idempotent.
#
# Usage: ./install.sh [--no-packages]
#   --no-packages   skip all package/tool installs, only (re)link configs
#
# Run as your normal user (not root); sudo is used where needed.

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

if [ "$EUID" -eq 0 ]; then
    echo "Run this as your normal user, not root (sudo is used where needed)." >&2
    exit 1
fi

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

read_list() {
    grep -vE '^\s*#|^\s*$' "$1" | sed 's/\s*#.*//'
}

# pacman with --noconfirm first; if that aborts (e.g. a conflict prompt whose
# default is "no"), retry interactively so the user can answer it.
pacman_install() {
    [ $# -eq 0 ] && return 0
    sudo pacman -S --needed --noconfirm "$@" || sudo pacman -S --needed "$@"
}

CONFIGS=(
    hypr
    noctalia
    alacritty
    fish
    fastfetch
    mimeapps.list
)

if [ "$SKIP_PACKAGES" -eq 0 ]; then
    if ! command -v pacman >/dev/null 2>&1; then
        echo "pacman not found - this script targets Arch Linux (use --no-packages to only link configs)" >&2
        exit 1
    fi

    # Ask for the password once and keep sudo alive for the whole run
    sudo -v
    while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

    step "Configuring pacman (multilib, parallel downloads, color)"
    if ! grep -qE '^\[multilib\]' /etc/pacman.conf; then
        if grep -qE '^#\[multilib\]' /etc/pacman.conf; then
            sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
        else
            printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' | sudo tee -a /etc/pacman.conf >/dev/null
        fi
        echo "Enabled [multilib]"
    fi
    sudo sed -i 's/^#Color/Color/; s/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf

    step "Updating system"
    sudo pacman -Syu --noconfirm

    step "Installing packages from packages.txt"
    mapfile -t WANTED < <(read_list "$DOTFILES_DIR/packages.txt")
    # Skip names that are not in the repos instead of failing the whole transaction
    AVAILABLE="$(pacman -Slq; pacman -Sgq)"
    PACKAGES=()
    for pkg in "${WANTED[@]}"; do
        if grep -qxF "$pkg" <<<"$AVAILABLE"; then
            PACKAGES+=("$pkg")
        else
            warn "Not in repos, skipping: $pkg"
        fi
    done
    pacman_install "${PACKAGES[@]}"

    step "Installing kernel headers (for nvidia/virtualbox DKMS modules)"
    HEADERS=()
    for kernel in linux linux-lts linux-zen linux-hardened; do
        if pacman -Q "$kernel" >/dev/null 2>&1; then
            HEADERS+=("$kernel-headers")
        fi
    done
    pacman_install "${HEADERS[@]}"

    # Each GPU vendor found is handled separately, so hybrid laptops
    # (Intel/AMD iGPU + NVIDIA dGPU) get drivers for both.
    GPUS="$(lspci 2>/dev/null | grep -iE 'vga|3d|display' || true)"

    if grep -qi nvidia <<<"$GPUS"; then
        step "NVIDIA GPU detected, installing drivers"
        pacman_install nvidia-open-dkms nvidia-utils lib32-nvidia-utils \
            nvidia-settings libva-nvidia-driver egl-wayland opencl-nvidia lib32-opencl-nvidia
    fi

    if grep -qi intel <<<"$GPUS"; then
        step "Intel GPU detected, installing Vulkan and VA-API drivers"
        pacman_install mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver
    fi

    if grep -qiE 'amd/ati|radeon' <<<"$GPUS"; then
        step "AMD GPU detected, installing Vulkan drivers"
        pacman_install mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
    fi

    if grep -q GenuineIntel /proc/cpuinfo; then
        pacman_install intel-ucode
    elif grep -q AuthenticAMD /proc/cpuinfo; then
        pacman_install amd-ucode
    fi

    step "Installing yay (AUR helper)"
    if ! command -v yay >/dev/null 2>&1; then
        YAY_BUILD="$(mktemp -d)"
        git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$YAY_BUILD/yay-bin"
        (cd "$YAY_BUILD/yay-bin" && makepkg -si --noconfirm)
        rm -rf "$YAY_BUILD"
    else
        echo "yay already installed"
    fi

    step "Installing AUR packages from packages-aur.txt"
    mapfile -t AUR_PACKAGES < <(read_list "$DOTFILES_DIR/packages-aur.txt")
    if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
        yay -S --needed --noconfirm --answerdiff None --answerclean None --removemake "${AUR_PACKAGES[@]}" \
            || warn "Some AUR packages failed - rerun: yay -S ${AUR_PACKAGES[*]}"
    fi

    step "Installing Flatpak apps from flatpaks.txt"
    if command -v flatpak >/dev/null 2>&1; then
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        mapfile -t FLATPAKS < <(read_list "$DOTFILES_DIR/flatpaks.txt")
        if [ ${#FLATPAKS[@]} -gt 0 ]; then
            sudo flatpak install -y --noninteractive flathub "${FLATPAKS[@]}" \
                || warn "Some flatpaks failed to install"
        fi
    fi

    step "Installing Rust (rustup, stable toolchain)"
    if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    else
        echo "rustup already installed"
    fi
    "$HOME/.cargo/bin/cargo" install --locked cargo-xwin || warn "cargo-xwin failed to install"

    step "Installing uv (Python package manager)"
    if [ ! -x "$HOME/.local/bin/uv" ]; then
        curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
    else
        echo "uv already installed"
    fi

else
    step "Skipping package install (--no-packages)"
fi

# Telegram, Happ and Spotify are only installed above - their own configs are
# intentionally NOT managed/symlinked by this repo.

step "Linking configs from $DOTFILES_DIR"

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

if command -v sddm >/dev/null 2>&1 || [ -d /etc/sddm.conf.d ] || pacman -Qi sddm >/dev/null 2>&1; then
    step "Setting up SDDM theme (where_is_my_sddm_theme, colours from Noctalia)"

    # The theme itself comes from packages-aur.txt (where-is-my-sddm-theme-git)
    if [ ! -d /usr/share/sddm/themes/where_is_my_sddm_theme ]; then
        warn "where_is_my_sddm_theme is not installed - run: yay -S where-is-my-sddm-theme-git"
    fi

    sudo mkdir -p /etc/sddm.conf.d
    sudo ln -sfn "$DOTFILES_DIR/config/sddm/theme.conf" /etc/sddm.conf.d/theme.conf
    echo "Linked sddm theme.conf"

    # Noctalia renders the palette into ~/.cache/noctalia/boot-theme/ and its
    # post_hook runs this root helper (passwordless, this one script only) to
    # recolour SDDM. The helper only writes validated hex colours.
    sudo install -m755 "$DOTFILES_DIR/config/sddm/noctalia-boot-theme" /usr/local/bin/noctalia-boot-theme
    SUDOERS_TMP="$(mktemp)"
    echo "$USER ALL=(root) NOPASSWD: /usr/local/bin/noctalia-boot-theme" >"$SUDOERS_TMP"
    if sudo visudo -cf "$SUDOERS_TMP" >/dev/null; then
        sudo install -m440 "$SUDOERS_TMP" /etc/sudoers.d/noctalia-boot-theme
        echo "Installed noctalia-boot-theme helper and sudoers rule"
    else
        warn "sudoers rule for noctalia-boot-theme failed validation, skipped"
    fi
    rm -f "$SUDOERS_TMP"

    # /etc/sddm.conf takes precedence over /etc/sddm.conf.d/*, so a leftover
    # Current= from a previously installed theme there would silently win.
    if [ -f /etc/sddm.conf ] && grep -qE '^Current=' /etc/sddm.conf; then
        echo "Removing conflicting Current= line from /etc/sddm.conf (leftover from another theme)"
        sudo cp /etc/sddm.conf /etc/sddm.conf.backup
        sudo sed -i '/^Current=/d' /etc/sddm.conf
    fi
else
    step "sddm not installed, skipping theme setup"
fi

step "Linking noctalia state (bar layout, enabled plugins)"

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

step "Linking local-path noctalia plugin (happ-control)"
# Everything else in settings.toml's [plugins] enabled list is a git/community
# plugin - Noctalia fetches those itself on startup. This one is sourced as a
# local path, so it needs to physically exist on disk.
mkdir -p "$HOME/Plugins"
if [ -e "$HOME/Plugins/happ-control" ] && [ ! -L "$HOME/Plugins/happ-control" ]; then
    echo "Backing up existing Plugins/happ-control"
    mv "$HOME/Plugins/happ-control" "$HOME/Plugins/happ-control.backup"
fi
ln -sfn "$DOTFILES_DIR/plugins/happ-control" "$HOME/Plugins/happ-control"

step "Linking scripts into ~/.local/bin"
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES_DIR"/bin/*; do
    ln -sfn "$script" "$HOME/.local/bin/$(basename "$script")"
    echo "Linked $(basename "$script")"
done

# Spotify from the app launcher goes through bin/spotify too (keeps Spicetify)
mkdir -p "$HOME/.local/share/applications"
if [ -f /usr/share/applications/spotify-launcher.desktop ]; then
    sed "s|^Exec=spotify-launcher|Exec=$HOME/.local/bin/spotify|" \
        /usr/share/applications/spotify-launcher.desktop \
        > "$HOME/.local/share/applications/spotify-launcher.desktop"
fi

step "Linking wallpaper"
mkdir -p "$HOME/Pictures"
if [ -e "$HOME/Pictures/Powerline.png" ] && [ ! -L "$HOME/Pictures/Powerline.png" ]; then
    echo "Backing up existing Pictures/Powerline.png"
    mv "$HOME/Pictures/Powerline.png" "$HOME/Pictures/Powerline.png.backup"
fi
ln -sfn "$DOTFILES_DIR/wallpapers/Powerline.png" "$HOME/Pictures/Powerline.png"

step "Nautilus: \"Open in Terminal\" uses alacritty"
# From a TTY there is no session bus, and gsettings would silently drop the
# write - spin up a temporary one so dconf actually saves it
if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then GSET=(gsettings); else GSET=(dbus-run-session gsettings); fi
"${GSET[@]}" set com.github.stunkymonkey.nautilus-open-any-terminal terminal alacritty 2>/dev/null \
    && echo "Set alacritty as Nautilus terminal" \
    || warn "nautilus-open-any-terminal is not installed - skipped"

step "Cursor: Bibata-Modern-Classic everywhere"
# Hyprland sets XCURSOR_* (environment.lua); GTK apps read gsettings, and
# X11/Electron apps that ignore both (Spotify) fall back to ~/.icons/default
CURSOR_THEME="Bibata-Modern-Classic"
CURSOR_SIZE=20
"${GSET[@]}" set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" 2>/dev/null || true
"${GSET[@]}" set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null || true
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nInherits=%s\n' "$CURSOR_THEME" > "$HOME/.icons/default/index.theme"
if command -v flatpak >/dev/null 2>&1; then
    # flatpaks can't see /usr/share/icons themes otherwise
    flatpak override --user --filesystem=/usr/share/icons:ro \
        --env=XCURSOR_THEME="$CURSOR_THEME" --env=XCURSOR_SIZE="$CURSOR_SIZE" 2>/dev/null || true
fi
echo "Cursor set to $CURSOR_THEME ($CURSOR_SIZE)"

step "Spotify: Spicetify + Comfy theme in Noctalia colors"
# Noctalia's "spicetify" template writes Themes/Comfy/color.ini and reapplies
# on every palette change; the theme itself has to be installed by hand
if command -v spicetify >/dev/null 2>&1; then
    COMFY="$CONFIG_DIR/spicetify/Themes/Comfy"
    if [ ! -d "$COMFY" ]; then
        COMFY_SRC="$(mktemp -d)"
        git clone -q --depth 1 https://github.com/Comfy-Themes/Spicetify "$COMFY_SRC" \
            && mkdir -p "$(dirname "$COMFY")" && cp -r "$COMFY_SRC/Comfy" "$COMFY"
        rm -rf "$COMFY_SRC"
    fi
    spicetify config current_theme Comfy color_scheme Comfy inject_css 1 replace_colors 1 \
        overwrite_assets 1 inject_theme_js 1 >/dev/null
    # needs Spotify launched (and logged in) once, so prefs exist
    if [ -f "$CONFIG_DIR/spotify/prefs" ]; then
        spicetify -q backup apply --no-restart && echo "Spicetify applied"
    else
        warn "Launch Spotify once, then run: spicetify backup apply"
    fi
else
    warn "spicetify-cli is not installed - skipped"
fi

if [ "$HOME" != "/home/geekd" ]; then
    warn "state/noctalia/settings.toml points wallpapers at /home/geekd/Pictures - pick the wallpaper again in Noctalia"
fi

if [ "$SKIP_PACKAGES" -eq 0 ] && command -v systemctl >/dev/null 2>&1; then
    step "Enabling services"
    enable_unit() {
        if systemctl list-unit-files "$1" >/dev/null 2>&1; then
            sudo systemctl enable "$1" >/dev/null 2>&1 && echo "Enabled $1" || warn "Could not enable $1"
        fi
    }
    for unit in NetworkManager.service bluetooth.service sddm.service docker.service \
                ufw.service avahi-daemon.service power-profiles-daemon.service \
                systemd-timesyncd.service fstrim.timer happd.service; do
        enable_unit "$unit"
    done

    if command -v ufw >/dev/null 2>&1; then
        sudo ufw default deny incoming >/dev/null
        sudo ufw default allow outgoing >/dev/null
        sudo ufw allow 53317 comment LocalSend >/dev/null
        sudo ufw --force enable >/dev/null && echo "ufw enabled (deny incoming, LocalSend port open)"
    fi

    step "User groups"
    for group in docker realtime; do
        if getent group "$group" >/dev/null && ! id -nG "$USER" | grep -qw "$group"; then
            sudo usermod -aG "$group" "$USER"
            echo "Added $USER to $group"
        fi
    done

    xdg-user-dirs-update 2>/dev/null || true
    sudo pkgfile --update >/dev/null 2>&1 || true

    if command -v fish >/dev/null 2>&1 && [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v fish)" ]; then
        step "Setting fish as login shell"
        sudo chsh -s "$(command -v fish)" "$USER"
    fi

    if [ -z "$(git config --global user.email 2>/dev/null)" ]; then
        git config --global user.email "geek228@proton.me"
    fi
fi

if command -v fish >/dev/null 2>&1; then
    step "Installing fish plugins (fisher)"
    fish -c "fisher update" || warn "fisher update failed"
fi

echo
echo "Done! Reboot and log in (Hyprland session)."
