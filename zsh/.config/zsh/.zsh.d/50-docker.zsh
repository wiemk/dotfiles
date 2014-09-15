# .zsh.d/50-docker.zsh

# mount host directories into the build container and build the package
docker-makepkg() {
    [[ ! -e PKGBUILD ]] && return 1
    local BUILDDIR CACHEDIR
    SCRATCHDIR=$(mktemp -d --tmpdir=$HOME/tmp build-XXXX)
    CACHEDIR=$(pwd)/pkg
    mkdir -p $CACHEDIR
    docker run --rm -u builder -v $CACHEDIR:/pkgcache -v $(pwd):/home/builder/build -v $SCRATCHDIR:/home/builder/tmp zeno/arch-makepkg:latest
    echo "removing $SCRATCHDIR"
    /bin/rm -rvfI $SCRATCHDIR
}

# build arch-makepkg
docker-build-arch-makepkg() {
    docker pull base/archlinux && \
        docker build --force-rm=true --tag="zeno/arch-makepkg" ~/dev/dockerfiles/arch-makepkg
}

# update base/archlinux image and rebuild arch-makepkg
docker-update-build-chain() {
    docker rmi -f zeno/arch-makepkg
    docker pull base/archlinux && \
        docker-build-arch-makepkg || \
    echo "Try docker-rmall first or remove the dependant container manually."
}

# trigger docker hub image rebuilds via webhook
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
