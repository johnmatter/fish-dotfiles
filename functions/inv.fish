function inv
    set -l cmd $argv[1]
    set -e argv[1]

    set -l invfile ~/.fish_inventory

    switch $cmd

        case stash
            for f in $argv
                if test -e $f
                    echo (realpath $f) >> $invfile
                else
                    echo "inv: file '$f' does not exist"
                end
            end

        case list
            if test -f $invfile
                cat $invfile
            else
                echo "(inventory is empty)"
            end

        case drop
            if test -f $invfile
                for f in (cat $invfile)
                    mv -v $f .
                end
                rm $invfile
            else
                echo "inv: nothing to drop"
            end

        case clear
            rm -f $invfile

        case '*'
            echo "Usage: inv (stash FILE... | list | drop | clear)"
    end
end
