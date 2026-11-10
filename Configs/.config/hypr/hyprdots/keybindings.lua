-- Keybindings, ported from keybindings.conf.
-- MOD is SUPER normally, ALT in preview (see helpers.lua).
-- https://wiki.hypr.land/Configuring/Binds/

local bind, s = hd.bind, hd.script
local dsp = hl.dsp

-- Apps (falls back to whatever is installed).
hd.terminal = hd.pick("kitty", "foot", "ghostty", "alacritty")
local editor = hd.pick("code", "code-oss", "nvim")
local file_manager = hd.pick("dolphin", "nautilus")
local browser = hd.pick("firefox", "zen-browser", "brave", "chromium", "google-chrome-stable")

-- Lua replacements for scripts that used the old `hyprctl dispatch` syntax.

-- dontkillsteam.sh: hide Steam instead of closing it.
local function close_window()
  local window = hl.get_active_window()
  if window and window.class == "Steam" then
    hl.exec_cmd("xdotool windowunmap $(xdotool getactivewindow)")
  else
    hl.dispatch(dsp.window.close())
  end
end

-- windowpin.sh: pinning needs a floating window, so float it first if needed
-- and drop back to tiling when unpinning.
local function toggle_pin()
  local window = hl.get_active_window()
  if not window then return end
  if not window.floating and not window.pinned then
    hl.dispatch(dsp.window.float({ action = "on" }))
  end
  hl.dispatch(dsp.window.pin())
  window = hl.get_active_window()
  if window and window.floating and not window.pinned then
    hl.dispatch(dsp.window.float({ action = "off" }))
  end
end

-- Nudge floating windows, swap tiled ones.
local function move_active(direction, x, y)
  return function()
    local window = hl.get_active_window()
    if window and window.floating then
      hl.dispatch(dsp.window.move({ x = x, y = y, relative = true }))
    else
      hl.dispatch(dsp.window.move({ direction = direction }))
    end
  end
end

local locked = { locked = true }
local locked_repeat = { locked = true, repeating = true }
local rofi = function(cmd) return "pkill -x rofi || " .. cmd end

-- Window/Session actions
hd.section("Window & session")
bind("MOD + SHIFT + P", "Color picker", "hyprpicker -a")
bind("MOD + Q", "Close window", close_window)
bind("ALT + F4", "Close window", close_window)
bind("MOD + Delete", "Exit Hyprland", dsp.exit())
bind("MOD + W", "Toggle floating", dsp.window.float({ action = "toggle" }))
bind("MOD + G", "Toggle group", dsp.group.toggle())
bind("ALT + Return", "Toggle fullscreen", dsp.window.fullscreen({ mode = "fullscreen" }))
bind("MOD + L", "Lock screen", "pidof hypridle >/dev/null && loginctl lock-session || pidof hyprlock || hyprlock")
bind("MOD + SHIFT + F", "Toggle pin", toggle_pin)
bind("MOD + Backspace", "Logout menu", s("logoutlaunch.sh"))
bind("CTRL + ALT + W", "Toggle waybar", "killall waybar || (env reload_flag=1 " .. s("wbarconfgen.sh") .. ")")

-- Application shortcuts
hd.section("Apps")
bind("MOD + T", "Terminal", hd.terminal)
bind("MOD + E", "File manager", file_manager)
bind("MOD + C", "Editor", editor)
bind("MOD + F", "Browser", browser)
bind("CTRL + SHIFT + Escape", "System monitor", s("sysmonlaunch.sh"))

-- Rofi menus
hd.section("Menus")
bind("MOD + A", "App launcher", rofi(s("rofilaunch.sh", "d")))
bind("MOD + Space", "App launcher", rofi(s("rofilaunch.sh", "d"))) -- Omarchy habit
bind("MOD + Tab", "Window switcher", rofi(s("rofilaunch.sh", "w")))
bind("MOD + SHIFT + E", "File search", rofi(s("rofilaunch.sh", "f")))

-- Audio
hd.section("Audio")
bind("F10", "Mute", s("volumecontrol.sh", "-o m"), locked)
bind("F11", "Volume down", s("volumecontrol.sh", "-o d"), locked_repeat)
bind("F12", "Volume up", s("volumecontrol.sh", "-o i"), locked_repeat)
bind("XF86AudioMute", "Mute", s("volumecontrol.sh", "-o m"), locked)
bind("XF86AudioMicMute", "Mute microphone", s("volumecontrol.sh", "-i m"), locked)
bind("XF86AudioLowerVolume", "Volume down", s("volumecontrol.sh", "-o d"), locked_repeat)
bind("XF86AudioRaiseVolume", "Volume up", s("volumecontrol.sh", "-o i"), locked_repeat)

-- Media
hd.section("Media")
bind("XF86AudioPlay", "Play/pause", "playerctl play-pause", locked)
bind("XF86AudioPause", "Play/pause", "playerctl play-pause", locked)
bind("XF86AudioNext", "Next track", "playerctl next", locked)
bind("XF86AudioPrev", "Previous track", "playerctl previous", locked)

-- Brightness
hd.section("Brightness")
bind("XF86MonBrightnessUp", "Brightness up", s("brightnesscontrol.sh", "i"), locked_repeat)
bind("XF86MonBrightnessDown", "Brightness down", s("brightnesscontrol.sh", "d"), locked_repeat)

-- Grouped windows
hd.section("Groups")
bind("MOD + CTRL + H", "Previous window in group", dsp.group.prev())
bind("MOD + CTRL + L", "Next window in group", dsp.group.next())

-- Screenshots
hd.section("Screenshots")
bind("MOD + P", "Screenshot area", s("screenshot.sh", "s"))
bind("MOD + CTRL + P", "Screenshot area (frozen)", s("screenshot.sh", "sf"))
bind("MOD + ALT + P", "Screenshot monitor", s("screenshot.sh", "m"))
bind("Print", "Screenshot all monitors", s("screenshot.sh", "p"))

-- HyprDots scripts
hd.section("HyprDots")
bind("MOD + ALT + G", "Game mode", s("gamemode.sh"))
bind("MOD + ALT + Right", "Next wallpaper", s("swwwallpaper.sh", "-n"))
bind("MOD + ALT + Left", "Previous wallpaper", s("swwwallpaper.sh", "-p"))
bind("MOD + ALT + Up", "Next waybar mode", s("wbarconfgen.sh", "n"))
bind("MOD + ALT + Down", "Previous waybar mode", s("wbarconfgen.sh", "p"))
bind("MOD + SHIFT + R", "Wallbash mode", rofi(s("wallbashtoggle.sh", "-m")))
bind("MOD + SHIFT + T", "Theme select", rofi(s("themeselect.sh")))
bind("MOD + SHIFT + A", "Rofi style select", rofi(s("rofiselect.sh")))
bind("MOD + SHIFT + X", "Theme style select", rofi(s("themestyle.sh")))
bind("MOD + SHIFT + W", "Wallpaper select", rofi(s("swwwallselect.sh")))
bind("MOD + V", "Clipboard", rofi(s("cliphist.sh", "c")))
bind("MOD + SHIFT + V", "Clipboard manager", rofi(s("cliphist.sh")))
bind("MOD + K", "Switch keyboard layout", s("keyboardswitch.sh"))
bind("MOD + slash", "Keybind hints", rofi(s("keybinds_hint.sh", "c")))
bind("MOD + ALT + A", "Animation select", rofi(s("animations.sh")))

-- Focus
hd.section("Focus")
bind("MOD + Left", "Focus left", dsp.focus({ direction = "l" }))
bind("MOD + Right", "Focus right", dsp.focus({ direction = "r" }))
bind("MOD + Up", "Focus up", dsp.focus({ direction = "u" }))
bind("MOD + Down", "Focus down", dsp.focus({ direction = "d" }))
bind("ALT + Tab", "Focus down", dsp.focus({ direction = "d" }))

-- Workspaces 1-10 (0 is 10)
hd.section("Workspaces")
for i = 1, 10 do
  local key = tostring(i % 10)
  local ws = tostring(i)
  bind("MOD + " .. key, "Workspace " .. ws, dsp.focus({ workspace = ws }))
  bind("MOD + SHIFT + " .. key, "Move window to workspace " .. ws, dsp.window.move({ workspace = ws }))
  bind("MOD + ALT + " .. key, "Move window silently to workspace " .. ws, dsp.window.move({ workspace = ws, follow = false }))
end

bind("MOD + CTRL + Right", "Next workspace", dsp.focus({ workspace = "r+1" }))
bind("MOD + CTRL + Left", "Previous workspace", dsp.focus({ workspace = "r-1" }))
bind("MOD + CTRL + Down", "First empty workspace", dsp.focus({ workspace = "empty" }))
bind("MOD + CTRL + ALT + Right", "Move window to next workspace", dsp.window.move({ workspace = "r+1" }))
bind("MOD + CTRL + ALT + Left", "Move window to previous workspace", dsp.window.move({ workspace = "r-1" }))
bind("MOD + mouse_down", "Next existing workspace", dsp.focus({ workspace = "e+1" }))
bind("MOD + mouse_up", "Previous existing workspace", dsp.focus({ workspace = "e-1" }))

-- Resize
hd.section("Resize & move")
local function resize(x, y) return dsp.window.resize({ x = x, y = y, relative = true }) end
bind("MOD + SHIFT + Right", "Grow right", resize(30, 0), { repeating = true })
bind("MOD + SHIFT + Left", "Shrink left", resize(-30, 0), { repeating = true })
bind("MOD + SHIFT + Up", "Shrink up", resize(0, -30), { repeating = true })
bind("MOD + SHIFT + Down", "Grow down", resize(0, 30), { repeating = true })

-- Move windows (the old file had an undefined $CONTROL here; CTRL was intended)
bind("MOD + SHIFT + CTRL + Left", "Move window left", move_active("l", -30, 0))
bind("MOD + SHIFT + CTRL + Right", "Move window right", move_active("r", 30, 0))
bind("MOD + SHIFT + CTRL + Up", "Move window up", move_active("u", 0, -30))
bind("MOD + SHIFT + CTRL + Down", "Move window down", move_active("d", 0, 30))

-- Mouse move/resize
bind("MOD + mouse:272", "Drag window", dsp.window.drag(), { mouse = true })
bind("MOD + mouse:273", "Resize window", dsp.window.resize(), { mouse = true })
bind("MOD + Z", "Drag window", dsp.window.drag(), { mouse = true })
bind("MOD + X", "Resize window", dsp.window.resize(), { mouse = true })

-- Scratchpad
hd.section("Scratchpad")
bind("MOD + ALT + S", "Move to scratchpad", dsp.window.move({ workspace = "special", follow = false }))
bind("MOD + S", "Toggle scratchpad", dsp.workspace.toggle_special())

-- Layout
hd.section("Layout")
bind("MOD + J", "Toggle split", dsp.layout("togglesplit"))
