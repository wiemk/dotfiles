# alias.zsh
#
# audio
dts2eac3() {
	(( $# < 2 )) && { echo "usage: dts2eac3 <src> <dst> [<bitrate>]"; return }
	(( $# == 2 )) && bitrate=640k || bitrate=$3
	ffmpeg -i $1 -map 0 -vcodec copy -scodec copy -acodec eac3 -b:a $bitrate $2
}

# dl
alias ydl="youtube-dl -icv --yes-playlist --no-call-home -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"
alias ydla="youtube-dl -icv --yes-playlist --no-call-home -f 'bestaudio[ext=m4a]'"

#  vim: set ft=zsh ts=4 sw=4 sts=0 tw=0 noet :
# EOF
