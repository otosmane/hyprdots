#!/usr/bin/env sh
# Close the focused window, but hide Steam instead of quitting it.
if [ "$(hyprctl activewindow -j | jq -r ".class")" = "Steam" ]; then
    xdotool windowunmap "$(xdotool getactivewindow)"
else
    hyprctl dispatch 'hl.dsp.window.close()'
fi
