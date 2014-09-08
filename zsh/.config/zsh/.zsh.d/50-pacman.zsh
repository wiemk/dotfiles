# .zsh.d/50-pacman.zsh
#########################################################################
# PACKAGE MANAGEMENT
#########################################################################
#
pm-modified() {
    pacman -Qii $1 | (
        local i
        while read -r i
        do
            [[ $i =~ '^MODIFIED' ]] && echo $i
        done
    )
}

pm-nodeps() {
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

pm-provisions() {
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

+pm-foreignfiles() {
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

+pm-foreigndirs() {
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
pm-size() {
    pacman -Qi "$@" 2>/dev/null |
        awk -F ": " -v filter="Size" -v pkg="Name" \
            '$0 ~ pkg {pkgname=$2} $0 ~ filter {gsub(/\..*/,"") ; printf("%6s KiB %s\n", $2, pkgname)}' |
        sort -u -k3 |
        tee >(awk '{TOTAL=$1+TOTAL} END {printf("Total : %d KiB\n",TOTAL)}')
}
pm-size2() { expac -Q '%m'| awk '{TOTAL+=$1} END {printf "Installed: %i MiB\n", TOTAL/1024^2}' }

# dependencies of package $1
pm-getdeps() { expac -l '\n' %E -S "$@" | sort -u }

# import and sign maintainer key
+pm-sign() { sudo -- sh -c 'pacman-key -r $1 && pacman-key --lsign-key $1' }

pm() { pacman "$@" }
+pm() { sudo pacman "$@" }
#

alias pm-ownedby='pm -Qo'
alias pm-orphans='pm -Qtd'
alias pm-listaur='pm -Qmq'
alias pm-checkinstalled='pm -Qkk'
alias pm-showlocal='pm -Qi'
alias pm-showremote='pm -Si'
alias pm-listfiles='pm -Ql'
alias pm-explicit='pm -Qet'
alias pm-listofficial='pm -Qn'
alias pm-reversedep='pactree -lrud1'
# privileged
alias pm-purge='+pm -Rnsc'
alias pm-adopt='+pm -D --asexplicit'
alias pm-abandon='+pm -D --asdeps'
alias pm-up='+pm -Syyu'
alias pm-purgeorphans='+pm -Rnsc $(pm -Qtdq)'

#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
