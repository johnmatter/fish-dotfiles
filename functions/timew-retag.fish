function timew-retag
    if test (count $argv) -ne 2
        echo "Usage: timew-retag OLD_TAG NEW_TAG"
        return 1
    end

    set old_tag $argv[1]
    set new_tag $argv[2]

    # Export all intervals and find those containing the old tag
    set ids (timew export \
        | jq -r --arg tag "$old_tag" '
            map(select(.tags[]? == $tag)) | .[].id
        ')

    if test -z "$ids"
        echo "No intervals found with tag '$old_tag'."
        return 0
    end

    # Add @ prefix for timew retag
    set ids_with_at
    for id in $ids
        set ids_with_at $ids_with_at "@$id"
    end

    # Join IDs with commas
    set id_list (string join , $ids_with_at)

    echo "Retagging intervals: $id_list → $new_tag"
    timew retag $id_list $new_tag
end
