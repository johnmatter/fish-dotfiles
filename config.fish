# PATH setup for Homebrew and MacTeX
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path /usr/local/texlive/2025/bin/universal-darwin

# host-specific configs
set host (hostname)
set host_config ~/.config/fish/conf.d/hostname-$host.fish
if test -f $host_config
    source $host_config
end

# Auto-sync fish colors with kitty theme
function sync_fish_colors_with_kitty
    set kitty_theme ~/.config/kitty/theme.conf
    if test -f $kitty_theme
        # Map kitty's ANSI colors to fish color variables
        set -U fish_color_command magenta           # Use kitty's color5
        set -U fish_color_comment yellow            # Use kitty's color3
        set -U fish_color_error red                 # Use kitty's color1
        set -U fish_color_param blue                # Use kitty's color4
        set -U fish_color_option blue               # Use kitty's color4
        set -U fish_color_quote green               # Use kitty's color2
        set -U fish_color_redirection cyan          # Use kitty's color6
        set -U fish_color_end magenta               # Use kitty's color5
        set -U fish_color_keyword magenta           # Use kitty's color5
        set -U fish_color_escape cyan               # Use kitty's color6
        set -U fish_color_operator cyan             # Use kitty's color6
        set -U fish_color_autosuggestion brblack    # Use kitty's color8

        # Keep existing ANSI color settings (already synced)
        # fish_color_cwd, fish_color_cwd_root, fish_color_status, fish_color_user
    end
end

# Manual function to refresh colors after changing kitty theme
function refresh_fish_colors
    sync_fish_colors_with_kitty
    echo "Fish colors refreshed to match current kitty theme!"
end

# Run the sync function on shell startup
sync_fish_colors_with_kitty

# Sync Base16 theme on shell startup
base16_theme

# bash-esque aliases
function vi; nvim $argv; end
function vim; nvim $argv; end
function l; ls -la; end
function tsc; source /Users/matter/coldtype/typesoundcode.feb2025/.venv/bin/activate.fish; end

# use startship for prompt
starship init fish | source
# starship preset gruvbox-rainbow -o ~/.config/starship.toml
# starship preset no-runtime-versions -o ~/.config/starship.toml

# set editor, mostly for lazygit but probably other stuff
set -gx EDITOR nvim lazygit
