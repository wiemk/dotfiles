# set path to weasel-pageant folder with set -Ux beforehand
#read -l rel < /proc/sys/kernel/osrelease
set -l target "$WEASEL_PATH/weasel-pageant"
if set -q WSLENV; and test -f "$target"
	eval (eval $target -a /tmp/ssh-agent.$USER.sock -q -r -S fish)
end
