function tovault --description 'Navigate to a vault directory for today or this week'
    if test (count $argv) -eq 0
        echo "Usage: tovault <vault-name> [date]"
        return 1
    end

    set vault_name $argv[1]

    # Build vault command with optional date argument
    if test (count $argv) -eq 2
        set vault_path (vault $vault_name $argv[2] --path-only 2>&1)
    else
        set vault_path (vault $vault_name --path-only 2>&1)
    end

    # Check if vault command succeeded
    if test $status -ne 0
        echo "Error: $vault_path"
        return 1
    end

    # Navigate to the directory
    cd $vault_path
end
