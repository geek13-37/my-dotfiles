source (status dirname)/cachyos/cachyos-config.fish

# no greeting (used to run fastfetch)
function fish_greeting
end

# opencode
fish_add_path -g ~/.opencode/bin

# Secrets (API keys and the like) live outside the repo
if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end
