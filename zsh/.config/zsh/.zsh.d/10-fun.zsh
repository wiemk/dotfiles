function fun_addandsign() {
    sudo -- sh -c 'pacman-key -r $1 && pacman-key --lsign-key $1'
}

function ukill() { 
    ps x -o  "%r %c " | grep $1 | awk -F' ' '{print $1}' | xargs -I % /bin/kill -TERM -- -%
}

function awp() {
    awk '{print $'$1'}';
}
