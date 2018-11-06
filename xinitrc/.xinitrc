#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources

fi


if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi


if [ -d /etc/X11/xinit/xinitrc.d ]; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi


declare units=(
  urxvtd
  unclutter
)

systemctl --user start ${units[@]}

# honor /etc/xdg/autostart
if [ hash dex 2>/dev/null ] ; then
	dex -a -e bspwm
else
	hash VBoxClient-all 2>/dev/null && { VBoxClient-all & }
	hash urxvtc 2>/dev/null && { urxvtc & }
fi

# disable display stuff if we are a virtualbox guest
if [ -c /dev/vboxguest 2>/dev/null ] ; then
	xset -dpms
	xset s noblank
	xset s noexpose
fi

# set correct mouse cursor and bg color
hash xsetroot 2>/dev/null && {
	xsetroot -cursor_name left_ptr
	xsetroot -solid "#272b30"
}
# adjust keyboard repeat rate
xset r rate 300 30

exec bspwm
