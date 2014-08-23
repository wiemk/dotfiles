# .zsh.d/10-fun.zsh
#########################################################################
# PACKAGE MANAGEMENT
#########################################################################
#
function pm_modified() {
    pacman -Qii $1 | (
        local i
        while read -r i
        do
            [[ $i =~ '^MODIFIED' ]] && echo $i
        done
    )
}

function pm_provisions() {
    expac -S "%n %P" |
        awk 'NF>1 {
            for(i=2; i<=NF; i++) {
                if(t[$i] == "")
                    t[$i]=""
                t[$i]=t[$i]" "$1
            }
        } END {
            for(p in t)
                printf("%44-s :%s\n", p, t[p])
        }' | sort | less
}

function pm_allmodified() { modified }
function pm_sign() { sudo -- sh -c 'pacman-key -r $1 && pacman-key --lsign-key $1' }

#########################################################################
# TEXT MANIPULATION
#########################################################################
#
function e() { 
    local editor=vim
    [[ -n $DISPLAY ]] && editor=gvim
    $editor --remote-tab-silent "$@"
}

# strip whitespaces, newlines and comments from stdin
function stripall() { sed -e 's/^[ \t]*//;s/[ \t]*$//' -e '/^$/d' -e '/^\#/d' -- }
# strip whitespaces
function stripwhitespace() { sed -e 's/^[ \t]*//;s/[ \t]*$//' -- }
# strip empty lines
function stripempty() { sed -e '/^$/d' -- }
# strip comments
function stripcomment() { sed -e '/^\#/d' -- }
# quick column select with standard whitespace delimeter
function awp() { awk '{print $'$1'}'; }

#########################################################################
# UTILITY & SIMPLIFICATION
#########################################################################
#
# simple extraction of various archive types
function x() {
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
function ngsudo {
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
# shortcuts
function cd() { builtin cd "$@" && ls -- }
#function ukill() { ps x -o  "%r %c " | grep $1 | awk -F' ' '{print $1}' | xargs -I % /bin/kill -TERM -- -% }
function +() { sudo "$@" }
function -() { builtin cd .. }
function @() { cat "$@" }
function p() { $PAGER "$@" }
function pm() { pacman "$@" }
function +pm() { sudo pacman "$@" }
function s() { systemctl "$@" }
function +s() { sudo systemctl "$@" }
function su() { systemctl --user "$@" }
function ?() { run-help "$1" }
#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
