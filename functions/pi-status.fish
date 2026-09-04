function pi-status --description 'Report whether the local MLX server is running, ready, and how much memory it holds'
    set -l port 8081
    set -l model mlx-community/Qwen3.6-35B-A3B-4bit

    set -l pid (pgrep -f "mlx_lm.server --model" | head -1)
    if test -z "$pid"
        echo "process:  not running"
        echo "          run pi-local to start it"
        return 1
    end

    # Uptime is here so a footprint reading can be judged as drift or a spike.
    set -l uptime (ps -o etime= -p $pid | string trim)
    echo "process:  running (pid $pid, up $uptime)"

    # Physical footprint is the only figure that sees Metal-backed allocations.
    # Measured against a loaded 19 GB model: ps rss said 4.7 GB and vm_stat's
    # "wired" said 4.2 GB, while footprint/top/vmmap all agreed on ~19-20 GB.
    # footprint is also the fastest of the three (~0.07s vs 1.7s for vmmap).
    set -l gb (footprint -p $pid 2>/dev/null | awk '/phys_footprint:/ {v=$2; u=$3; if(u=="KB") v/=1048576; else if(u=="MB") v/=1024; else if(u=="TB") v*=1024; printf "%.1f\n", v; exit}')
    set -l total (math -s0 (sysctl -n hw.memsize) / 1073741824)
    if test -z "$gb"
        echo "memory:   footprint unavailable"
        set gb 0
    else
        echo "memory:   $gb GB footprint  ($total GB machine)"
    end

    if curl -s -m 3 -o /dev/null "http://127.0.0.1:$port/v1/models"
        echo "http:     answering on port $port"
    else
        echo "http:     NOT answering on port $port"
        return 1
    end

    # Only a real completion proves the weights are resident. /v1/models answers
    # from a static catalog in ~0.03s even while the model is still loading.
    set -l t0 (date +%s)
    set -l body (printf '{"model":"%s","messages":[{"role":"user","content":"hi"}],"max_tokens":1}' $model)
    if curl -sf -m 60 -o /dev/null -X POST "http://127.0.0.1:$port/v1/chat/completions" \
            -H 'Content-Type: application/json' -d "$body"
        echo "ready:    yes (probe took "(math (date +%s) - $t0)"s)"
    else
        echo "ready:    NO — up but cannot serve, most likely still loading weights"
        return 1
    end

    # 32 GB machine; a Metal OOM was observed once total pressure passed ~27 GB.
    if test (math -s0 $gb) -ge 24
        echo "note:     footprint is high — pi-local-restart reclaims it"
    end
end
