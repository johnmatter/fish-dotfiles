function theme
  if test (count $argv) -eq 0
    # Show current theme if no arguments
    if test -f ~/.config/.theme
      echo "Current theme: "(cat ~/.config/.theme)
    else
      echo "No theme set"
    end
    return
  end
  
  set theme_name $argv[1]
  
  # Write theme to file
  echo $theme_name > ~/.config/.theme
  
  # Apply the theme
  base16_theme
  
  echo "Theme changed to: $theme_name"
end 