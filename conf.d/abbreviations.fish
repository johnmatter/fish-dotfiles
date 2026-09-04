# Abbreviations — expand inline at the command line.
# Unlike functions/aliases, the real command lands in history & completions.

abbr -a tw timew
abbr -a tv tovault
abbr -a lg lazygit
abbr -a td vault todo
abbr -a cs /Users/matter/Games/earthbound/CoilSnake/bin/coilsnake-cli
abbr -a git-branch 'git log --oneline --graph --all --decorate --simplify-by-decoration'
abbr -a dot 'git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
abbr -a yt-dlp-wav 'yt-dlp -x --audio-format wav'
abbr -a yt-mp4 'yt-dlp -t mp4'

# coldtype's `ct` lives in its own venv (skia + glfw viewer); the bare `ct` on
# PATH is a homebrew build without the viewer extra. Expand to the full one.
abbr -a ct '~/coldtype/coldtype/.venv/bin/ct'
