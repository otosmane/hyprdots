#!/usr/bin/env bash
# Open the HyprDots config in a nested Hyprland window inside your current session.
# Inside the preview, ALT is the main key (your real session keeps SUPER).
# ALT + Delete closes the preview.
#
# The config also detects a nested launch by itself, but only this script can
# stop Hyprland from pushing its variables into your systemd session
# (HYPRLAND_NO_SD_VARS), so use it rather than launching Hyprland by hand.

dir="$(cd "$(dirname "$0")" && pwd)/Configs/.config/hypr"

HYPRDOTS_PREVIEW=1 HYPRLAND_NO_SD_VARS=1 exec Hyprland --config "$dir/hyprland.lua"
