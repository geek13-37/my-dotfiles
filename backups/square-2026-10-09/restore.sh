#!/bin/sh
# Restore the square (rounding = 0) look
D="$(cd "$(dirname "$0")" && pwd)"
cp "$D/look.lua" "$HOME/my-dotfiles/config/hypr/config/look.lua"
cp "$D/settings.toml" "$HOME/my-dotfiles/state/noctalia/settings.toml"
hyprctl reload >/dev/null 2>&1
echo "square rice restored (restart noctalia if it didn't pick up the change)"
