function pi-local --description 'Start the local MLX server if needed, then run pi'
    set -l model mlx-community/Qwen3.6-35B-A3B-4bit
    set -l port 8081
    set -l logdir $HOME/.local/state/pi
    set -l log $logdir/mlx-server.log

    if not curl -s -m 2 "http://127.0.0.1:$port/v1/models" >/dev/null 2>&1
        # Port 8080 is held by bookserve; 8081 is ours. If something else has
        # taken it, say so rather than spawning a server that cannot bind.
        if lsof -nP -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1
            echo "pi-local: port $port is in use but not answering as an MLX server:" >&2
            lsof -nP -iTCP:$port -sTCP:LISTEN >&2
            return 1
        end

        mkdir -p $logdir
        echo "pi-local: starting $model on port $port (~40s to load)…"
        nohup mlx_lm.server --model $model --port $port >>$log 2>&1 &
        disown

        set -l waited 0
        while not curl -s -m 2 "http://127.0.0.1:$port/v1/models" >/dev/null 2>&1
            sleep 2
            set waited (math $waited + 2)
            if test $waited -ge 180
                echo "pi-local: server did not become ready in 180s. Log: $log" >&2
                return 1
            end
        end
        echo "pi-local: ready after {$waited}s"
    end

    exec pi $argv
end
