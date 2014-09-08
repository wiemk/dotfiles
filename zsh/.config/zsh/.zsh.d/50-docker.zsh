# .zsh.d/50-docker.zsh

docker-makepkg() {
    BUILDDIR=$(mktemp -d --tmpdir=$HOME/tmp build-XXXX)
    docker run --rm -v $(pwd):/build -v $BUILDDIR:/scratch zeno/arch-pkgbuild
    /bin/rm -rvI $BUILDDIR
}

docker-build-arch-devel() {
    docker build --force-rm=true --tag="zeno/arch-devel" ~/dev/system/docker/arch-devel
}

docker-build-arch-pkgbuild() {
    docker build --force-rm=true --tag="zeno/arch-devel" ~/dev/system/docker/arch-pkgbuild
}

docker-update-build-chain() {
    docker rmi -f zeno/arch-devel
    docker rmi -f zeno/arch-pkgbuild
    docker-build-arch-devel
    docker-build-arch-pkgbuild
}

# Delete all containers
alias docker-rmall="docker rm $(docker ps -a -q)"
# Delete all images
alias docker-rmiall="docker rmi $(docker images -q)"

#
#
# EOF
# vim :set ft=zsh ts=4 sw=4 sts=4 et :
