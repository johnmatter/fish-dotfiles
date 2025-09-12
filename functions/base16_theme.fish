function base16_theme
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
      
      if test -f $kitty_theme_256
        kitty @ set-colors -c $kitty_theme_256
      else if test -f $kitty_theme
        kitty @ set-colors -c $kitty_theme
      end
    end
  end
end 