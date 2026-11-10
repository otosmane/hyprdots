#!/usr/bin/env bash

# Restores the shader after screenshot has been taken
restore_shader() {
	if [ -n "$shader" ]; then
		hyprshade on "$shader"
	fi
}

# Saves the current shader and turns it off
save_shader() {
	command -v hyprshade >/dev/null || return
	shader=$(hyprshade current)
	hyprshade off
	trap restore_shader EXIT
}

save_shader # Saving the current shader

if [ -z "$XDG_PICTURES_DIR" ]; then
	XDG_PICTURES_DIR="$HOME/Pictures"
fi

scrDir=$(dirname "$(realpath "$0")")
source $scrDir/globalcontrol.sh
swpy_dir="${confDir}/swappy"
save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
temp_screenshot="/tmp/screenshot.png"

mkdir -p $save_dir
mkdir -p $swpy_dir
echo -e "[Default]\nsave_dir=$save_dir\nsave_filename_format=$save_file" >$swpy_dir/config

function print_error
{
	cat <<"EOF"
    ./screenshot.sh <action>
    ...valid actions are...
        p  : print all screens
        s  : snip current screen
        sf : snip current screen (frozen)
        m  : print focused monitor
EOF
}

# grimblast is no longer packaged; grim + slurp do the same job.
focused_output() { hyprctl -j monitors | jq -r '.[] | select(.focused) | .name'; }

# Area picker that also lets you click a window to grab it whole.
pick_area() {
	slurp -d -o -r -c "#cba6f7ff" -b "#11111b66" -B "#00000000" < <(
		hyprctl -j clients | jq -r --argjson ws "$(hyprctl -j activeworkspace | jq .id)" \
			'.[] | select(.workspace.id == $ws and .mapped and (.hidden | not)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
	)
}

# Freeze the screen while picking, the way Omarchy does it.
freeze() { hyprpicker -r -z >/dev/null 2>&1 & freeze_pid=$!; sleep 0.1; }
unfreeze() { [ -n "$freeze_pid" ] && kill "$freeze_pid" 2>/dev/null; }

capture() { grim "$@" "$temp_screenshot" && wl-copy < "$temp_screenshot"; }
edit() { restore_shader && swappy -f "$temp_screenshot"; }

case $1 in
p) # print all outputs
	capture && edit ;;
s) # drag to manually snip an area / click on a window to print it
	area="$(pick_area)" && [ -n "$area" ] && capture -g "$area" && edit ;;
sf) # frozen screen, drag to manually snip an area / click on a window to print it
	freeze
	area="$(pick_area)"
	unfreeze
	[ -n "$area" ] && capture -g "$area" && edit ;;
m) # print focused monitor
	capture -o "$(focused_output)" && edit ;;
*) # invalid option
	print_error ;;
esac

rm -f "$temp_screenshot"

if [ -f "${save_dir}/${save_file}" ]; then
	notify-send -a "t1" -i "${save_dir}/${save_file}" "saved in ${save_dir}"
fi
