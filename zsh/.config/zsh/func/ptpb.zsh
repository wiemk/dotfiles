pb () {
  curl -F "c=@${1:--}" https://ptpb.pw/
}

pbx () {
  curl -sF "c=@${1:--}" -w "%{redirect_url}" 'https://ptpb.pw/?r=1' -o /dev/stderr | xsel -l /dev/null -b
}

pbs () {
  gm import -window ${1:-root} /tmp/$$.png
  pbx /tmp/$$.png
}
