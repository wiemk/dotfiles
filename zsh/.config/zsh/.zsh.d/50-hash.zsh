# .zsh.d/50-hash.zsh
#
# Directory hashes
HASHES=(~/dev ~/.dotfiles)

HASHES=($^HASHES(N))
for (( i=${#HASHES[@]}; i > 0; --i )); do
    for k ("${HASHES[$i]}"/*(/)); do
        hash -d "${k##*/}=$k"
    done
done
unset HASHES i

#
# EOF
# vim :set ts=4 sw=4 sts=4 et :
