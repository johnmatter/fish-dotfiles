# ThinkPad (Ubuntu 24.04, Qtile/Plasma) host config.

# PATH. fish_add_path is idempotent, unlike the `set -gx PATH ... $PATH` lines
# it replaced, which appended a duplicate every time the file was sourced.
# Note these calls do not set the order: entries already in the universal
# fish_user_paths keep their stored position, so PATH order comes from
# fish_variables, not from the order here.
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin

alias gr='rg'

# Qt apps (Dolphin et al.) read their palette from kdeglobals. Without this
# they fall back to Fusion's default under Qtile, where no desktop portal
# advertises a theme — so they alone ignore the base16 scheme everything
# else follows.
set -gx QT_QPA_PLATFORMTHEME kde
