#!/usr/bin/env sh
# Toggle pin on the focused window. Pinning needs a floating window, so float it
# first and drop it back to tiling when unpinning.

state() { hyprctl activewindow -j | jq -r "\"\(.floating) \(.pinned)\""; }

[ "$(state)" = "false false" ] && hyprctl dispatch 'hl.dsp.window.float({ action = "on" })'
hyprctl dispatch 'hl.dsp.window.pin()'
[ "$(state)" = "true false" ] && hyprctl dispatch 'hl.dsp.window.float({ action = "off" })'
exit 0
