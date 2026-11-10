#!/usr/bin/env bash
# Keybind hints: list every HyprDots bind in rofi, grouped by section,
# and run the one you pick.
#
# The list is written by hyprland.lua (hd.write_bind_list) each time the
# config loads, because `hyprctl binds` can't show what a Lua bind does.
#
# Options:
#   -p   print the list to the terminal instead of opening rofi
#   -w   rofi width  (default 40em)
#   -h   rofi height (default 35em)
#   -l   rows shown  (default 13)

pkill -x rofi && exit
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -p) kb_hint_pretty=true ;;
    -w) shift; kb_hint_width="$1" ;;
    -h) shift; kb_hint_height="$1" ;;
    -l) shift; kb_hint_line="$1" ;;
    c) ;; # old flag from the waybar/keybind callers, no longer needed
    *) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  esac
  shift
done

runtime="${XDG_RUNTIME_DIR:-/tmp}"
list="$runtime/hyprdots-binds.tsv"
[ "$HYPRDOTS_PREVIEW" = "1" ] && list="$runtime/hyprdots-binds-preview.tsv"

if [ ! -s "$list" ]; then
  notify-send -a "t1" "Keybind hints" "No bind list yet. Reload Hyprland (hyprctl reload) and try again."
  exit 1
fi

# One row per bind: "<keys>  <description>", with a header row per section.
# Each bind row carries its index as rofi "info" metadata; headers carry none,
# so picking a header does nothing.
menu="$(awk -F '\t' '
  function pretty(k) {
    gsub(/SUPER/, "󰻀", k)
    gsub(/mouse_down/, "scroll down", k); gsub(/mouse_up/, "scroll up", k)
    gsub(/XF86AudioRaiseVolume/, "Vol +", k); gsub(/XF86AudioLowerVolume/, "Vol -", k)
    gsub(/XF86AudioMicMute/, "Mic mute", k); gsub(/XF86AudioMute/, "Mute", k)
    gsub(/XF86AudioPlay/, "Play", k); gsub(/XF86AudioPause/, "Pause", k)
    gsub(/XF86AudioNext/, "Next", k); gsub(/XF86AudioPrev/, "Prev", k)
    gsub(/XF86MonBrightnessUp/, "Bright +", k); gsub(/XF86MonBrightnessDown/, "Bright -", k)
    return k
  }
  $2 != last { if (NR > 1) print ""; print "━━ " $2 " ━━"; last = $2 }
  { printf "%-28s  %s\x1finfo\x1f%s\n", pretty($3), $4, $1 }
' "$list")"

if [ "$kb_hint_pretty" = true ] || ! command -v rofi >/dev/null; then
  sed 's/\x1finfo\x1f.*//' <<< "$menu"
  exit 0
fi

# Match the launcher's look: rounding and border from the live Hyprland config.
wind_border=$(( ${hypr_border:-0} * 3 / 2 ))
elem_border=$([ "${hypr_border:-0}" -eq 0 ] && echo 5 || echo "$hypr_border")
r_override="window { width: ${kb_hint_width:-40em}; height: ${kb_hint_height:-35em}; border: ${hypr_width:-0}px; border-radius: ${wind_border}px; } entry { border-radius: ${elem_border}px; } element { border-radius: ${elem_border}px; } listview { lines: ${kb_hint_line:-13}; }"
icon_theme="$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")"

idx="$(printf '%s\n' "$menu" | rofi -dmenu -i -p "Keybinds" -format 'i' \
  -matching fuzzy -no-custom \
  -theme-str "configuration { font: \"JetBrainsMono Nerd Font 10\"; icon-theme: \"${icon_theme}\"; }" \
  -theme-str "$r_override" \
  -config "$confDir/rofi/clipboard.rasi")"
[ -z "$idx" ] && exit 0

# rofi -format i gives the row number; look up the bind index stored on that row.
bind="$(printf '%s\n' "$menu" | sed -n "$(( idx + 1 ))p" | sed -n 's/.*\x1finfo\x1f//p')"
[ -n "$bind" ] && hyprctl eval "hd.run_bind($bind)" >/dev/null
