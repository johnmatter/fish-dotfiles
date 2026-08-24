function pi-local --description 'Start the local MLX server if needed, then run pi'
    set -l model mlx-community/Qwen3.6-35B-A3B-4bit
    set -l port 8081
    set -l logdir $HOME/.local/state/pi
    set -l log $logdir/mlx-server.log

    # /v1/models answers from a static catalog before weights are resident, so it
    # cannot tell us the server can actually serve. A 1-token completion can.
    set -l probe_body (printf '{"model":"%s","messages":[{"role":"user","content":"hi"}],"max_tokens":1}' $model)

    function __pi_local_probe --no-scope-shadowing
        curl -sf -m 20 -o /dev/null -X POST "http://127.0.0.1:$port/v1/chat/completions" \
            -H 'Content-Type: application/json' -d "$probe_body"
    end

    if not __pi_local_probe
        # Port 8080 is held by bookserve; 8081 is ours. If something else has
        # taken it, say so rather than spawning a server that cannot bind.
        if lsof -nP -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1
            # Something already holds the port. If it is our own MLX server still
            # loading weights, wait for it rather than failing.
            set -l holder (lsof -nP -iTCP:$port -sTCP:LISTEN -t | head -1)
            if not ps -p $holder -o command= | string match -q '*mlx_lm.server*'
                echo "pi-local: port $port is in use but not answering as an MLX server:" >&2
                lsof -nP -iTCP:$port -sTCP:LISTEN >&2
                functions -e __pi_local_probe
                return 1
            end
            echo "pi-local: MLX server already up but still loading; waiting…"
        else
            mkdir -p $logdir
            echo "pi-local: starting $model on port $port (~40s to load)…"
            nohup mlx_lm.server --model $model --port $port >>$log 2>&1 &
            disown
        end

        set -l t0 (date +%s)
        while not __pi_local_probe
            sleep 2
            set -l elapsed (math (date +%s) - $t0)
            if test $elapsed -ge 300
                functions -e __pi_local_probe
                echo "pi-local: server did not become ready in 300s. Log: $log" >&2
                return 1
            end
        end
        echo "pi-local: ready after "(math (date +%s) - $t0)"s"
    end

    functions -e __pi_local_probe
    exec pi $argv
end
