# Skip a command from shell history if it was typed with a leading space.
# Mirrors bash's HISTCONTROL=ignorespace. Useful for `--password '...'` etc.
function __skip_space_history --on-event fish_preexec
    if string match -q ' *' -- $argv[1]
        history delete --exact --case-sensitive -- $argv[1]
    end
end
