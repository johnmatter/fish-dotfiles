function themes
  echo "Available Base16 themes:"
  echo "========================"
  
  # List all base16 themes from kitty directory
  for file in ~/.config/base16-kitty/colors/base16-*.conf
    set theme_name (basename $file | sed 's/base16-//' | sed 's/.conf$//' | sed 's/-256$//')
    echo $theme_name
  end | sort -u | column -c 80
  
  echo ""
  echo "Usage:"
  echo "  theme <name>           - Apply theme"
  echo "  theme                  - Show current theme" 
  echo "  <leader>ct (in nvim)   - Interactive picker with previews"
end 