# .zsh.d/90-pkgglob.zsh
# depends on pkgfile
if [ -e /usr/share/doc/pkgfile/command-not-found.zsh ]; then
    source /usr/share/doc/pkgfile/command-not-found.zsh
fi

#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
