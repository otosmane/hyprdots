#!/usr/bin/env sh
# Toggle game mode: no animations, blur, shadows, gaps or rounding.

if [ "$(hyprctl -j getoption animations:enabled | jq -r '.int // (if .bool then 1 else 0 end)')" = "1" ]; then
    gaming=1
else
    gaming=0
fi

# Waybar: comment out animations/transitions while gaming.
FILE="$HOME/.config/waybar/style.css"
if [ -f "$FILE" ]; then
    sed -i 's/\/\* \(.*animation:.*\) \*\//\1/g; s/\/\* \(.*transition:.*\) \*\//\1/g' "$FILE"
    if [ "$gaming" = 1 ]; then
        sed -i 's/^\(.*animation:.*\)$/\/\* \1 \*\//g; s/^\(.*transition:.*\)$/\/\* \1 \*\//g' "$FILE"
    fi
    killall waybar
    waybar >/dev/null 2>&1 &
fi

if [ "$gaming" = 1 ]; then
    hyprctl eval 'hl.config({
        animations = { enabled = false },
        decoration = { rounding = 0, shadow = { enabled = false }, blur = { enabled = false } },
        general = { gaps_in = 0, gaps_out = 0, border_size = 1 },
    })'
    notify-send -a "t1" -r 91192 -t 1500 "Game mode on"
else
    hyprctl reload
    notify-send -a "t1" -r 91192 -t 1500 "Game mode off"
fi
