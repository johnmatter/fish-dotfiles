function vimgit
  # Get all modified files (both staged and unstaged changes)
  set -l modified_files (git status --porcelain | /usr/bin/grep -E '^[AMRC]|^.[MR]|^\?\?' | cut -c4-)
  
  # If no modified files found, exit
  if test (count $modified_files) -eq 0
    echo "No modified files found"
    return 0
  end
  
  # Open all modified files in vim tabs
  if test (count $modified_files) -gt 0
    echo "Opening modified files in vim tabs: $modified_files"
    vim -p $modified_files
  end
end
