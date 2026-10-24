source (status dirname)/cachyos/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # colours from the Caelestia scheme (config/caelestia/templates/fastfetch.args)
    set -l colours ~/.local/state/caelestia/theme/fastfetch.args
    if test -f $colours
        fastfetch (cat $colours)
    else
        fastfetch
    end
end
