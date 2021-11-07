# vi:set ft=bash ts=4 sw=4 noet noai:
on_debug

if ! has koji; then
	return
fi

chkpkg() {
	echo -n "$*" \
		| tr ' ' '\0' \
		| xargs -P8 -L1 -0 koji list-builds --state=COMPLETE --after="$(env LC_ALL=C date -d -'2 days')" --package
}
