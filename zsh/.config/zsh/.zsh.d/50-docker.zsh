# .zsh.d/50-docker.zsh

docker-makepkg() {
    [[ ! -e PKGBUILD ]] && return 1
    local BUILDDIR CACHEDIR
    SCRATCHDIR=$(mktemp -d --tmpdir=$HOME/tmp build-XXXX)
    CACHEDIR=$(pwd)/pkg
    mkdir -p $CACHEDIR
    docker run --rm -v $(pwd):/build -v $CACHEDIR:/pkgcache -v $SCRATCHDIR:/scratch zeno/arch-pkgbuild
    echo "removing $SCRATCHDIR"
    /bin/rm -rvfI $SCRATCHDIR
}

docker-build-arch-devel() {
    docker build --force-rm=true --tag="zeno/arch-devel" ~/dev/dockerfiles/arch-devel
}

docker-build-arch-pkgbuild() {
    docker build --force-rm=true --tag="zeno/arch-pkgbuild" ~/dev/dockerfiles/arch-pkgbuild
}

docker-update-build-chain() {
    docker rmi -f zeno/arch-devel &&
    docker rmi -f zeno/arch-pkgbuild &&
    docker-build-arch-devel &&
    docker-build-arch-pkgbuild ||
    echo "Try docker-rmall first or remove the dependant container manually."
}

docker-trigger-rebuild() {
    local trigger="$HOME/dev/dockerfiles/$1/trigger"
    if [[ -e "$trigger" ]]; then
        read line < "$trigger"
        if [[ -n "$line" ]]; then
            curl --data "build=true" -X POST "$line"
        else
            echo >&2 "No URL in $trigger found."
        fi
    else
        echo >&2 "No trigger found: $trigger"
    fi
}

# Delete all containers
docker-rmall() { docker rm $(docker ps -a -q) }
# Delete all images
docker-rmiall() { docker rmi $(docker images -q) }

#
#
# EOF
# vim :set ft=zsh ts=4 sw=4 sts=4 et :
