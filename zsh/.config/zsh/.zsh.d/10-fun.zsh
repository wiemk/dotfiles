function modified() {
    pacman -Qii $1 | \
        while read -r i
        do
            [[ $i =~ '^MODIFIED' ]] && echo $i
        done
}

function fun_addandsign() { sudo -- sh -c 'pacman-key -r $1 && pacman-key --lsign-key $1' }
function ukill() { ps x -o  "%r %c " | grep $1 | awk -F' ' '{print $1}' | xargs -I % /bin/kill -TERM -- -% }
function showallmodified() { modified }
function stripall() { sed -e 's/^[ \t]*//;s/[ \t]*$//' -e '/^$/d' -e '/^\#/d' -- }
function stripwhitespace() { sed -e 's/^[ \t]*//;s/[ \t]*$//' -- }
function stripempty() { sed -e '/^$/d' -- }
function stripcomment() { sed -e '/^\#/d' -- }
function awp() { awk '{print $'$1'}'; }
function +() { sudo "$@" }
function -() { builtin cd .. }
function @() { cat "$@" }
function p() { $PAGER "$@" }
