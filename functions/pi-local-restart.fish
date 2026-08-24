function pi-local-restart --description 'Restart the local MLX server to reclaim wired memory'
    pkill -f 'mlx_lm.server --model mlx-community' >/dev/null 2>&1
    set -l killed $status
    sleep 3
    if test $killed -eq 0
        echo "pi-local-restart: server stopped."
    else
        echo "pi-local-restart: no running server found (nothing to stop)."
    end
    echo "pi-local-restart: largest resident processes:"
    ps -Ao rss=,command= | sort -rn | head -3 | awk '{printf "  %.1f GB  %s\n", $1/1048576, substr($0, index($0,$2))}'
    echo "Run pi-local to start it again."
end
