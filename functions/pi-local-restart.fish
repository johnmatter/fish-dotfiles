function pi-local-restart --description 'Restart the local MLX server to reclaim wired memory'
    pkill -f 'mlx_lm.server --model mlx-community' >/dev/null 2>&1
    sleep 3
    echo "pi-local-restart: server stopped. Wired memory now:"
    vm_stat | grep 'wired down'
    echo "Run pi-local to start it again."
end
