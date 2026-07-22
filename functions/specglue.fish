function specglue --description "Bake a time-synced spectrogram strip (with moving playhead) onto a video clip"
    argparse s/solo 'H/height=' -- $argv
    or return

    set -l input $argv[1]
    if test -z "$input"
        echo "usage: specglue [--solo] [--height N] input.mp4" >&2
        echo "  default: stacks a spectrogram strip under the original video" >&2
        echo "  --solo:  spectrogram-only video carrying the original audio" >&2
        return 1
    end

    set -l height 240
    set -q _flag_height; and set height $_flag_height
    set -l width 1920

    set -l dur (ffprobe -v error -show_entries format=duration -of csv=p=0 -- $input)
    if test -z "$dur"
        echo "specglue: could not read duration of $input" >&2
        return 1
    end

    set -l out (path change-extension '' -- $input)-spec.mp4
    set -l png (mktemp -t specglue).png

    # Pass 1: full-clip spectrogram image. legend=0 is load-bearing — the
    # legend adds margins that would break the time→pixel mapping.
    set -l size $width"x"$height
    ffmpeg -hide_banner -loglevel error -y -i $input \
        -lavfi "showspectrumpic=s=$size:legend=0:scale=log:fscale=log" $png
    or begin
        rm -f $png
        return 1
    end

    # Pass 2: sweep a playhead cursor across the strip over the clip's duration.
    set -l cursorx "(main_w-overlay_w)*t/$dur"

    if set -q _flag_solo
        set -l filter "[0:v][2:v]overlay=x='$cursorx':y=0,format=yuv420p[v]"
        ffmpeg -hide_banner -loglevel error -y \
            -loop 1 -i $png -i $input -f lavfi -i "color=c=white:s=4x$height:r=30" \
            -filter_complex $filter \
            -map '[v]' -map 1:a -t $dur -r 30 \
            -c:v h264_videotoolbox -b:v 4M -c:a aac -b:a 192k $out
    else
        set -l filter "[1:v]scale=$width:-2[main];[0:v][2:v]overlay=x='$cursorx':y=0[spec];[main][spec]vstack,format=yuv420p[v]"
        ffmpeg -hide_banner -loglevel error -y \
            -loop 1 -i $png -i $input -f lavfi -i "color=c=white:s=4x$height:r=30" \
            -filter_complex $filter \
            -map '[v]' -map 1:a -t $dur \
            -c:v h264_videotoolbox -b:v 10M -c:a aac -b:a 192k $out
    end
    set -l ffmpeg_status $status
    rm -f $png
    test $ffmpeg_status -eq 0; and echo $out
end
