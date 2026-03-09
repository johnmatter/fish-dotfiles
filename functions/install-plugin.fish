function install-plugin --description 'Copy a built plugin to its install directory'
    argparse 's/system' -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo "Usage: install-plugin [--system] <plugin-path> [plugin-path...]"
        return 1
    end

    for plugin in $argv
        if not test -e $plugin
            echo "Error: $plugin does not exist"
            continue
        end

        set -l ext (string match -r '\\.(vst3|component|clap)$' $plugin)
        switch $ext[2]
            case vst3
                set -f dest_dir (set -q _flag_system && echo $VST3_SYSTEM_DIR || echo $VST3_USER_DIR)
            case component
                set -f dest_dir (set -q _flag_system && echo $AU_SYSTEM_DIR || echo $AU_USER_DIR)
            case clap
                set -f dest_dir (set -q _flag_system && echo $CLAP_SYSTEM_DIR || echo $CLAP_USER_DIR)
            case '*'
                echo "Error: Unrecognized plugin format: $plugin"
                echo "       Expected .vst3, .component, or .clap"
                continue
        end

        set -l name (basename $plugin)
        set -l cmd cp -r $plugin $dest_dir/
        if set -q _flag_system
            echo "sudo cp -r $name → $dest_dir/"
            sudo $cmd
        else
            echo "cp -r $name → $dest_dir/"
            $cmd
        end
    end
end
