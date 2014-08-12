function fun_purge() {
    sudo pacman -Rnsc $1
}
function fun_purgeorphans() {
    sudo pacman -Rnsc $(pacman -Qtdq)
}
function fun_showremote() {
    pacman -Si $1
}
function fun_showlocal() {
    pacman -Qi $1
}
function fun_listfiles() {
    pacman -Ql $1
}
function fun_adopt() {
    sudo pacman -D --asexplicit $1
}
function fun_abandon() {
    sudo pacman -D --asdeps $1
}
function fun_ownedby() {
    pacman -Qo $1
}
function fun_addandsign() {
    sudo -- sh -c 'pacman-key -r $1 && pacman-key --lsign-key $1'
}
function fun_checkmodified() {
    pacman -Qii $1
}
function fun_performance() {
    perf top -g -p $1
}

function ukill() { 
    ps x -o  "%r %c " | grep $1 | awk -F' ' '{print $1}' | xargs -I % /bin/kill -TERM -- -%
}

