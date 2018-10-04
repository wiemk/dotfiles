set -l target '/mnt/c/Users/zeno/Tools/weasel-pageant/weasel-pageant'
#read -l rel < /proc/sys/kernel/osrelease
#if string match -q -- "*Microsoft" $rel -a test -f $target
if set -q WSLENV; and test -f $target
	eval (/mnt/c/Users/zeno/Tools/weasel-pageant/weasel-pageant -q -r -S fish)
end
