# alias.zsh
#
ydl() {
	(( $# < 1 )) && { return }
	youtube-dl \
		-icv \
		--yes-playlist \
		--no-call-home \
		-f 'bestvideo+bestaudio/best' \
		--merge-output-format mp4 \
		--recode-video mp4 \
		--postprocessor-args "-c copy" \
		--external-downloader=aria2c \
		"$@"
}

# EOF
