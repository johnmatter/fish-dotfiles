function yt-mp4
  set yt_url $argv[1]
  yt-dlp -t mp4 $yt_url
end
