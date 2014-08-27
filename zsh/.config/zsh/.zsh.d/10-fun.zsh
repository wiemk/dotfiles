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

function pm_nodeps() {
    local ignoregrp="base base-devel"
    local ignorepkg=
    comm -23 <(
        pacman -Qqt |
        sort
    ) <(
        echo $ignorepkg |
        tr ' ' '\n' |
        cat <(pacman -Sqg $ignoregrp) - |
        sort -u
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

function +pm_foreignfiles() {
    # no traps here due to being a interactive shell function
    # it would persist after being triggered
    local p=$1
    local tmp=$(mktemp)
    (( $# == 0 )) && p="/"
    sudo find $p \( \
        -path '/dev' \
        -o -path '/sys' \
        -o -path '/run' \
        -o -path '/tmp' \
        -o -path '/mnt' \
        -o -path '/srv' \
        -o -path '/proc' \
        -o -path '/boot' \
        -o -path '/home' \
        -o -path '/root' \
        -o -path '/media' \
        -o -path '/var/lib/pacman' \
        -o -path '/var/lib/container' \
        -o -path '/var/cache/pacman' \
    \)  -prune -o -type f -print > $tmp 2>/dev/null
    comm -23 <(sort -u $tmp) <(pacman -Qlq | sort -u)
    command rm -f $tmp
}

function +pm_foreigndirs() {
    local p=$1
    local tmp=$(mktemp)
    (( $# == 0 )) && p="/"
    sudo find $p \( \
        -path '/dev' \
        -o -path '/sys' \
        -o -path '/run' \
        -o -path '/tmp' \
        -o -path '/mnt' \
        -o -path '/srv' \
        -o -path '/proc' \
        -o -path '/boot' \
        -o -path '/home' \
        -o -path '/root' \
        -o -path '/media' \
        -o -path '/var/lib/pacman' \
        -o -path '/var/lib/container' \
        -o -path '/var/cache/pacman' \
    \)  -prune -o -type d -print > $tmp 2>/dev/null
    comm -23 <(sed 's/\([^/]\)$/\1\//' $tmp | sort -u) <(pacman -Qlq | sort -u)
    command rm -f $tmp
}

# specific & total size of local packages
function pm_size() {
    pacman -Qi "$@" 2>/dev/null |
        awk -F ": " -v filter="Size" -v pkg="Name" \
            '$0 ~ pkg {pkgname=$2} $0 ~ filter {gsub(/\..*/,"") ; printf("%6s KiB %s\n", $2, pkgname)}' |
        sort -u -k3 |
        tee >(awk '{TOTAL=$1+TOTAL} END {printf("Total : %d KiB\n",TOTAL)}')
}

# dependencies of package $1
function pm_getdeps() { expac -l '\n' %E -S "$@" | sort -u }

# import and sign maintainer key
function +pm_sign() { sudo -- sh -c 'pacman-key -r $1 && pacman-key --lsign-key $1' }

#########################################################################
# TEXT MANIPULATION
#########################################################################
#
# buffer version
function e() {
    local editor=vim
    [[ -n $DISPLAY ]] && editor=gvim
    (( $# > 0 )) && $editor --remote-silent "$@" || $editor --remote-silent .
}
# tab version
function et() {
    local editor=vim
    [[ -n $DISPLAY ]] && editor=gvim
    (( $# > 0 )) && $editor --remote-tab-silent "$@" || $editor --remote-tab-silent .
}
#
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
# enclose a line in $1
function enclose() { sed "s/.*/$1&$1/" -- }

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
# simple and quick HTTP Server
function sweb {
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
function shost {
    local cmd='/usr/lib/systemd/systemd-resolve-host'
    if [[ -x $cmd ]]; then
        $cmd "$@"
    else
        echo "$cmd not found."
    fi
}
# shortcuts
#function ukill() { ps x -o  "%r %c " | grep $1 | awk -F' ' '{print $1}' | xargs -I % /bin/kill -TERM -- -% }
function cd() { builtin cd "$@" && ls -- }
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

# EOF
# vim :set ts=4 sw=4 sts=4 et :
