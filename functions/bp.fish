function bp --description "Browse branch proposal workbenches"
    set -l base_dir "$HOME/Music/madrona/nightly-explore/workbench"
    set -l filter "$argv[1]"
    set -l entries

    for repo_dir in $base_dir/bp-*/*/
        test -d "$repo_dir/.git"; or continue

        set -l rel (string replace "$base_dir/" "" "$repo_dir")
        set -l rel_clean (string trim --right --chars='/' "$rel")
        set -l parts (string split '/' "$rel_clean")
        set -l bp_id $parts[1]
        set -l repo_name $parts[2]

        set -l branch (git -C "$repo_dir" branch --show-current 2>/dev/null)
        if test -z "$branch"
            set branch "(detached)"
        end

        set -l stat (git -C "$repo_dir" diff --cached --shortstat 2>/dev/null | string trim)

        set -l repo_path (string trim --right --chars='/' "$repo_dir")
        set -a entries (string join \t -- "$repo_path" "$bp_id" "$repo_name" "$branch" "$stat")
    end

    if test (count $entries) -eq 0
        echo "No branch proposal workbenches found."
        return 1
    end

    if test -n "$filter"
        set -l filtered
        for entry in $entries
            if string match -qi "*$filter*" "$entry"
                set -a filtered "$entry"
            end
        end
        set entries $filtered
        if test (count $entries) -eq 0
            echo "No workbenches matching '$filter'."
            return 1
        end
    end

    set -l preview_cmd 'repo={1}; echo "=== $(git -C "$repo" branch --show-current 2>/dev/null) ==="; echo; stat=$(git -C "$repo" diff --cached --stat --color=always 2>/dev/null); if [ -n "$stat" ]; then echo "$stat"; echo; git -C "$repo" diff --cached --color=always 2>/dev/null; else echo "(no staged changes)"; echo; git -C "$repo" status --short 2>/dev/null; fi'

    set -l result (printf '%s\n' $entries | env SHELL=/bin/sh fzf \
        --delimiter='\t' \
        --with-nth=2.. \
        --header='enter: lazygit  ctrl-p: promote  ctrl-n: nvim  ctrl-d: cd' \
        --preview="$preview_cmd" \
        --preview-window='right:50%:wrap' \
        --ansi \
        --expect='ctrl-n,ctrl-d,ctrl-p' \
        --tabstop=4 \
        --no-sort \
        --layout=reverse)

    test (count $result) -ge 1; or return 0
    set -l key $result[1]
    set -l selection $result[2]
    test -n "$selection"; or return 0

    set -l fields (string split \t "$selection")
    set -l repo_path $fields[1]
    set -l repo_name $fields[3]
    set -l branch $fields[4]

    switch "$key"
        case 'ctrl-p'
            set -l main_repo "$HOME/Music/madrona/$repo_name"
            if not test -d "$main_repo/.git"
                echo "Main repo not found: $main_repo"
                return 1
            end
            if git -C "$main_repo" rev-parse --verify "$branch" >/dev/null 2>&1
                echo "Branch '$branch' already exists in $main_repo"
                return 1
            end
            if test -z "$(git -C "$repo_path" diff --cached --name-only 2>/dev/null)"
                echo "No staged changes to promote."
                return 1
            end

            echo "Promote '$branch' → $repo_name"
            read -l -P "Commit message (ctrl-c to cancel): " -c "$branch" commit_msg
            or return 0

            git -C "$repo_path" commit -m "$commit_msg"
            and git -C "$main_repo" fetch "$repo_path" "$branch:$branch"
            and echo "Branch '$branch' is now in $main_repo"
            and uv run --project "$HOME/Music/madrona/nightly-explore" python -c "
import db; db.init_db(); db.set_proposal_status('$bp_id', 'done'); print('DB: $bp_id → done')"
            or echo "Promote failed."
        case 'ctrl-n'
            nvim $repo_path
        case 'ctrl-d'
            cd $repo_path
        case '*'
            lazygit -p $repo_path
    end
end
