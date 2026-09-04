# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/miniconda3/bin/conda
    eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/miniconda3/etc/fish/conf.d/conda.fish"
        . "/opt/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

# PATH. fish_add_path is idempotent, unlike the `set -gx PATH ... $PATH` lines
# this replaced, which appended a duplicate every time the file was sourced.
# Note these calls do not set the order: entries already in the universal
# fish_user_paths keep their stored position, so PATH order comes from
# fish_variables, not from the order here.
fish_add_path /usr/local/texlive/2025/bin/universal-darwin
fish_add_path /opt/homebrew/sbin
fish_add_path /opt/homebrew/bin
fish_add_path /usr/local/bin
fish_add_path ~/.cargo/bin

# alias cat='bat'
alias gr='rg'

# Audio plugin directories (macOS layout; Linux uses ~/.vst3, ~/.clap, no AU)
set -gx VST3_USER_DIR ~/Library/Audio/Plug-Ins/VST3
set -gx VST3_SYSTEM_DIR /Library/Audio/Plug-Ins/VST3
set -gx AU_USER_DIR ~/Library/Audio/Plug-Ins/Components
set -gx AU_SYSTEM_DIR /Library/Audio/Plug-Ins/Components
set -gx CLAP_USER_DIR ~/Library/Audio/Plug-Ins/CLAP
set -gx CLAP_SYSTEM_DIR /Library/Audio/Plug-Ins/CLAP

function tsc; source /Users/matter/coldtype/typesoundcode.feb2025/.venv/bin/activate.fish; end

# Load the SSH signing key from the macOS keychain if the agent is empty.
ssh-add -l > /dev/null 2>&1; or ssh-add --apple-load-keychain > /dev/null 2>&1
