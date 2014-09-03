# .zsh.d/50-pacman.zsh
#########################################################################
# PACKAGE MANAGEMENT
#########################################################################
#
pm_modified() {
    pacman -Qii $1 | (
        local i
        while read -r i
        do
            [[ $i =~ '^MODIFIED' ]] && echo $i
        done
    )
}

pm_nodeps() {
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

pm_provisions() {
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

+pm_foreignfiles() {
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

+pm_foreigndirs() {
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
pm_size() {
    pacman -Qi "$@" 2>/dev/null |
        awk -F ": " -v filter="Size" -v pkg="Name" \
            '$0 ~ pkg {pkgname=$2} $0 ~ filter {gsub(/\..*/,"") ; printf("%6s KiB %s\n", $2, pkgname)}' |
        sort -u -k3 |
        tee >(awk '{TOTAL=$1+TOTAL} END {printf("Total : %d KiB\n",TOTAL)}')
}
pm_size2() { expac -Q '%m'| awk '{TOTAL+=$1} END {printf "Installed: %i MiB\n", TOTAL/1024^2}' }

# dependencies of package $1
pm_getdeps() { expac -l '\n' %E -S "$@" | sort -u }

# import and sign maintainer key
+pm_sign() { sudo -- sh -c 'pacman-key -r $1 && pacman-key --lsign-key $1' }

pm() { pacman "$@" }
+pm() { sudo pacman "$@" }
#

alias pm_ownedby='pm -Qo'
alias pm_orphans='pm -Qtd'
alias pm_listaur='pm -Qmq'
alias pm_checkinstalled='pm -Qkk'
alias pm_showlocal='pm -Qi'
alias pm_showremote='pm -Si'
alias pm_listfiles='pm -Ql'
alias pm_explicit='pm -Qet'
alias pm_listofficial='pm -Qn'
alias pm_reversedep='pactree -lrud1'
# privileged
alias pm_purge='+pm -Rnsc'
alias pm_adopt='+pm -D --asexplicit'
alias pm_abandon='+pm -D --asdeps'
alias pm_up='+pm -Syyu'
alias pm_purgeorphans='+pm -Rnsc $(pm -Qtdq)'

#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
