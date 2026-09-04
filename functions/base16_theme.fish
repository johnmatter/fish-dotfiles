function base16_theme
  # Everything below is local to the desktop session: kitty remote control,
  # rofi, qtile. Over SSH the OSC palette write would repaint the *client's*
  # terminal, which already has its own theme applied.
  if set -q SSH_CONNECTION; or set -q SSH_TTY
    return
  end

  set theme_file ~/.config/.theme
  if test -f $theme_file
    set theme_name (cat $theme_file | head -1)
    set base16_script ~/.config/base16-shell/scripts/base16-$theme_name.sh

    if test -f $base16_script
      # Source the base16 shell script which sets up proper terminal colors
      bash $base16_script

      # Also apply kitty theme
      set kitty_theme_256 ~/.config/base16-kitty/colors/base16-$theme_name-256.conf
      set kitty_theme ~/.config/base16-kitty/colors/base16-$theme_name.conf

      set kitty_conf
      if test -f $kitty_theme_256
        set kitty_conf $kitty_theme_256
      else if test -f $kitty_theme
        set kitty_conf $kitty_theme
      end

      if test -n "$kitty_conf"
        # Two ways to reach kitty. The socket never touches the tty, so it works
        # from inside tmux. The DCS fallback does not: tmux swallows the escape
        # sequence, kitty never receives it, and the kitten just burns the time
        # bound accomplishing nothing - so skip it under TMUX rather than pay
        # for a guaranteed no-op. Bound both; a dead socket should degrade the
        # same way. kitty 0.32 has no native --timeout, and the kitten ignores
        # SIGTERM while blocked on a read, so -k is required to actually stop it.
        if set -q KITTY_LISTEN_ON
          timeout -k 1 2 kitty @ --to $KITTY_LISTEN_ON set-colors -c $kitty_conf
        else if set -q KITTY_WINDOW_ID; and not set -q TMUX
          timeout -k 1 2 kitty @ set-colors -c $kitty_conf
        end
      end

      # Generate rofi colors
      set rofi_script ~/.config/rofi/generate-colors.sh
      if test -x $rofi_script
        bash $rofi_script >/dev/null 2>&1
      end

      # Reload qtile to apply new theme colors
      qtile cmd-obj -o cmd -f reload_config >/dev/null 2>&1
    end
  end
end
