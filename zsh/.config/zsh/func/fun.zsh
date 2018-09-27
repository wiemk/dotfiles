# fun.zsh
#########################################################################
# TEXT MANIPULATION
#########################################################################
#
# strip whitespaces, newlines and comments from stdin
stripall() { sed -e 's/^[ \t]*//;s/[ \t]*$//' -e '/^$/d' -e '/^\#/d' -- }
# strip whitespaces
stripwhitespace() { sed -e 's/^[ \t]*//;s/[ \t]*$//' -- }
# strip empty lines
stripempty() { sed -e '/^$/d' -- }
# strip comments
stripcomment() { sed -e '/^\#/d' -- }
# quick column select with standard whitespace delimeter
awp() { awk '{print $'$1'}'; }
# enclose a line in $1
enclose() { sed "s/.*/$1&$1/" -- }

#########################################################################
# UTILITY & SIMPLIFICATION
#########################################################################
#
# simple extraction of various archive types
x() {
	if [[ $# -eq 0 ]]; then
		printf '%s\n' "usage: x <archive1> [<archive2> [...]]"
		return 1
	fi
	while (( $# > 0 )); do
		case "$1" in
			*.tar.gz | *.tgz) bsdtar -xvzf "$1";;
			*.tar.bz2 | *.tbz) bsdtar -xvjf "$1";;
			*.7z) 7za x "$1";;
			*.bz2) bunzip2 "$1";;
			*.gz) gunzip -k "$1";;
			*.rar) unrar e -ad "$1";;
			*.zip) unzip "$1";;
			*) bsdtar -xvf "$1";;
		esac
		shift
	done
}
# noglob for sudo
ngsudo() {
	while [[ $# > 0 ]]; do
		case "$1" in
		command) shift ; break ;;
		nocorrect|noglob) shift ;;
		*) break ;;
		esac
	done
	if [[ $# = 0 ]]; then
		command sudo zsh
	else
		noglob command sudo $@
	fi
}
# simple and quick HTTP Server
sweb() {
	local -i port=8080
	local host=0.0.0.0
	if (( $# > 0 )); then
		port=$1
		(( $port == 0 )) && port=8080
		if (( $# > 1 )); then
			host=$2
		fi
	fi
	/usr/bin/env python3 -m http.server $port --bind $host
}

# display images in terminal
img() {
	for image in "$@"; do
		convert -thumbnail $(tput cols) "$image" txt:- |
			awk -F '[)(,]' '!/^#/{gsub(/ /,"");printf"\033[48;2;"$3";"$4";"$5"m "}'
		echo -e "\e[0;0m"
	done
}

# create symbolic link to tmpfs folder
mktmpfslink() {
	if [[ -d "$HOME/tmp" ]]; then
		local scratch folder="$1"
		[[ -z "$folder" ]] && folder='tmp'
		local scratch=$(mktemp -d --tmpdir="$HOME/tmp" link-XXXX)
		ln -s "$scratch" "$folder"
	else
		echo >&2 "No ~/tmp found."
		return 1
	fi
}

# remove link target and link
rmtarget() {
	if [[ -d "$1" ]]; then
		local folder
		if folder=$(readlink -f "$1"); then
			echo >&2 "Going to remove $1 -> $folder"
			rm -rvfI "$folder" "$1"
		fi
	else
		echo >&2 "$1 not found."
		return 1
	fi
}

colorbar() {
	awk 'BEGIN{
		s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
		for (colnum = 0; colnum<77; colnum++) {
			r = 255-(colnum*255/76);
			g = (colnum*510/76);
			b = (colnum*255/76);
			if (g>255) g = 510-g;
			printf "\033[48;2;%d;%d;%dm", r,g,b;
			printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
			printf "%s\033[0m", substr(s,colnum+1,1);
		}
		printf "\n";
	}'
}

# shortcuts
#ukill() { ps x -o	"%r %c " | grep $1 | awk -F' ' '{print $1}' | xargs -I % /bin/kill -TERM -- -% }
c() { builtin cd "$@" && ls -- }
+() { sudo "$@" }
-() { builtin cd .. }
@() { cat "$@" }
rh() { run-help "$1" }
punsh() { curl -F c=@- https://p.unsha.re/ }

# EOF
