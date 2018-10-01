function ydla
    command youtube-dl -icv --yes-playlist --no-call-home -f 'bestaudio[ext=m4a]' -x --audio-quality 0 --external-downloader=aria2c "$argv"
end
