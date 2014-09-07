# .zsh.d/50-systemd.zsh
#########################################################################
# SYSTEMD
#########################################################################
#

systemd-alias() {
    local c user_commands sudo_commands
    user_commands=(list-units is-active status show help list-unit-files is-enabled list-jobs show-environment)
    sudo_commands=(start stop daemon-reload reload restart try-restart isolate kill reset-failed enable disable reenable preset mask unmask link load cancel set-environment unset-environment)

    for c in $user_commands; do
        alias sc-$c="systemctl $c"
        alias scu-$c="systemctl --user $c"
    done
    for c in $sudo_commands; do
        alias sc-$c="sudo systemctl $c"
        alias scu-$c="systemctl --user $c"
    done
}

systemd-alias

#
sc() { systemctl --system "$@" }
+sc() { sudo systemctl --system "$@" }
scu() { systemctl --user "$@" }

# journald
jc() { journalctl --system "$@" }
jcu() { journalctl --user "$@" }

# no pager
jcn() { jc --no-pager "$@" }
jcun() { jcu --no-pager "$@" }

#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
