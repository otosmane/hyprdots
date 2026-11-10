--      ░▒▒▒░░░░░▓▓          ___________
--    ░░▒▒▒░░░░░▓▓        //___________/
--   ░░▒▒▒░░░░░▓▓     _   _ _    _ _____
--   ░░▒▒░░░░░▓▓▓▓▓▓ | | | | |  | |  __/
--    ░▒▒░░░░▓▓   ▓▓ | |_| | |_/ /| |___
--     ░▒▒░░▓▓   ▓▓   \__  |____/ |____/
--       ░▒▓▓   ▓▓  //____/
--
-- HyprDots, ported to Hyprland's Lua config (0.57+).
-- The old .conf files next to this one are kept for reference only.

-- Resolve paths from this file's location, so the same config works from
-- ~/.config/hypr or straight out of the repo for previewing.
local config_dir = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$")

local function dir_exists(path)
  local f = io.open(path .. "/.", "r")
  if f then f:close() return true end
  return false
end

-- Drop cached modules so a config reload picks up edits.
for name in pairs(package.loaded) do
  if name == "hyprdots" or name:sub(1, 9) == "hyprdots." then
    package.loaded[name] = nil
  end
end
package.path = config_dir .. "/?.lua;" .. package.path

-- Shared state for the modules.
hd = {}
hd.config_dir = config_dir
hd.home = os.getenv("HOME")

-- Preview mode runs inside your current session: no background daemons,
-- no gsettings or systemd changes, ALT instead of SUPER.
--
-- It turns on by itself whenever Hyprland is nested in another session, so
-- a test run can never touch the session it runs inside, even without
-- preview.sh. Two checks, because a reload changes the environment:
--   * first load: a real login starts with no WAYLAND_DISPLAY; a nested
--     launch inherits the outer session's.
--   * reloads: a nested Hyprland's outputs are named WAYLAND-n or X11-n
--     (real screens are eDP-1, DP-1, HDMI-A-1 and so on).
local function nested()
  local monitors = hl.get_monitors() or {}
  if #monitors == 0 then
    return os.getenv("WAYLAND_DISPLAY") ~= nil
  end
  for _, monitor in ipairs(monitors) do
    local name = tostring(monitor.name)
    if name:match("^WAYLAND%-") or name:match("^X11%-") then
      return true
    end
  end
  return false
end

hd.nested = nested()
hd.preview = os.getenv("HYPRDOTS_PREVIEW") == "1" or hd.nested

-- Hyprland copies its cursor into gsettings on startup, which in preview
-- would change the cursor of the session it runs inside.
if hd.preview then
  hl.config({ cursor = { sync_gsettings_theme = false } })
end

-- Scripts: the repo copy when previewing, the installed copy otherwise.
local repo_scripts = config_dir .. "/../../.local/share/bin"
if hd.preview and dir_exists(repo_scripts) then
  hd.scr_path = repo_scripts
else
  hd.scr_path = hd.home .. "/.local/share/bin"
end

require("hyprdots.helpers")
require("hyprdots.env")
require("hyprdots.autostart")
require("hyprdots.input")
require("hyprdots.looknfeel")
require("hyprdots.animations")
require("hyprdots.keybindings")
require("hyprdots.windowrules")
-- require("hyprdots.nvidia") -- uncomment on NVIDIA GPUs

-- Personal overrides, loaded last so they win.
require("hyprdots.monitors")
require("hyprdots.userprefs")

-- After userprefs, so your own hd.bind() calls show up in the hints menu.
hd.write_bind_list()
