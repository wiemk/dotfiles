# .zsh.d/10-fun.zsh
#########################################################################
# TEXT MANIPULATION
#########################################################################
#
# buffer version
eb() {
    local editor=vim
    [[ -n $DISPLAY ]] && editor=gvim
    (( $# > 0 )) && $editor --remote-silent "$@" || $editor --remote-silent .
}
# tab version
e() {
    local editor=vim
    [[ -n $DISPLAY ]] && editor=gvim
    (( $# > 0 )) && $editor --remote-tab-silent "$@" || $editor --remote-tab-silent .
}
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

# use systemd resolver
shost() {
    local cmd='/usr/lib/systemd/systemd-resolve-host'
    if [[ -x $cmd ]]; then
        $cmd "$@"
    else
        echo "$cmd not found."
    fi
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
        local folder="$1"
        [[ -z "$folder" ]] && folder='tmp'
        local scratch=$(mktemp -d --tmpdir=$HOME/tmp link-XXXX)
        ln -s "$scratch" "$folder"
    else
        echo >&2 "No ~/tmp found."
    fi
}

# shortcuts
#ukill() { ps x -o  "%r %c " | grep $1 | awk -F' ' '{print $1}' | xargs -I % /bin/kill -TERM -- -% }
cd() { builtin cd "$@" && ls -- }
+() { sudo "$@" }
-() { builtin cd .. }
@() { cat "$@" }
p() { $PAGER "$@" }
?() { run-help "$1" }

#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
