# vi:set ft=sh ts=4 sw=4 noet noai:
# shellcheck shell=bash
# shellcheck disable=2155,1090

init_debug

radeon-profile() {
  local -r fpl=/sys/class/drm/card0/device/power_dpm_force_performance_level
  local -r ppm=/sys/class/drm/card0/device/pp_power_profile_mode
  if [[ ! -f $fpl ]]; then
    return 1
  fi
  local -r pp=$(
    tail -n +2 <$ppm |
      fzf \
        --no-sort \
        --cycle \
        --height=10 \
        --layout=reverse-list \
        --border=rounded \
        --prompt='mode# ' \
        --info=inline |
      awk '{print $1}'
  )
  if [[ -z $pp ]]; then
    return 1
  fi
  if ((UID != 0)); then
    local -r priv=1
  fi
  echo "manual" | ${priv:+sudo} tee "$fpl" >/dev/null
  echo "$pp" | ${priv:+sudo} tee "$ppm" >/dev/null
  grep -E "^[[:space:]]*${pp}" "$ppm"
}
