function clip
  if test (count $argv) -lt 3
    echo "Usage: clip <filename> <start> <duration>"
    echo "Example: clip video.mp4 00:01:30 00:00:10"
    return 1
  end

  set -l input $argv[1]
  set -l start $argv[2]
  set -l duration $argv[3]

  if not test -f $input
    echo "Error: File '$input' not found"
    return 1
  end

  set -l ext (string match -r '\.[^.]+$' $input)
  set -l base (string replace -r '\.[^.]+$' '' $input)
  set -l output "$base"_clip"$ext"

  ffmpeg -ss $start -i $input -t $duration -c copy $output
end
