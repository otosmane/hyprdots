-- Small helpers shared by the HyprDots modules.

local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close() return true end
  return false
end

function hd.cmd_present(command)
  for dir in ((os.getenv("PATH") or "/usr/bin") .. ":"):gmatch("([^:]*):") do
    if dir ~= "" and file_exists(dir .. "/" .. command) then
      return true
    end
  end
  return false
end

-- First installed command from a list, or the first entry as a fallback.
function hd.pick(...)
  local candidates = { ... }
  for _, command in ipairs(candidates) do
    if hd.cmd_present(command) then
      return command
    end
  end
  return candidates[1]
end

function hd.script(name, args)
  return hd.scr_path .. "/" .. name .. (args and (" " .. args) or "")
end

-- In preview, SUPER belongs to the host session, so MOD becomes ALT.
hd.mod = hd.preview and "ALT" or "SUPER"

local seen = {}
hd.skipped_binds = 0

-- Every bind, in order, for the keybind hints menu (keybinds_hint.sh).
-- `hyprctl binds` can't show what a Lua bind does, so we keep our own list.
hd.binds = {}
hd.section_name = "General"

function hd.section(name)
  hd.section_name = name
end

-- Canonical "MODS+KEY" so duplicate combos can be detected.
local function canonical(keys)
  local parts = {}
  for part in keys:gmatch("[^+]+") do
    parts[#parts + 1] = part:match("^%s*(.-)%s*$")
  end
  local key = table.remove(parts)
  local mods, set = {}, {}
  for _, mod in ipairs(parts) do
    mod = mod:upper()
    if mod == "CONTROL" then mod = "CTRL" end
    if set[mod] then return nil end -- e.g. MOD + ALT when MOD is ALT
    set[mod] = true
    mods[#mods + 1] = mod
  end
  table.sort(mods)
  mods[#mods + 1] = key:lower()
  return table.concat(mods, "+")
end

-- hd.bind("MOD + SHIFT + T", "Description", action, opts)
-- action: a shell command string, a hl.dsp dispatcher, or a Lua function.
function hd.bind(keys, description, action, opts)
  keys = keys:gsub("MOD", hd.mod)
  local id = canonical(keys)
  if not id or seen[id] then
    -- Only happens in preview, where MOD and ALT collapse into one key.
    hd.skipped_binds = hd.skipped_binds + 1
    return
  end
  seen[id] = true

  opts = opts or {}
  opts.description = description
  if type(action) == "string" then
    action = hl.dsp.exec_cmd(action)
  end
  hl.bind(keys, action, opts)

  -- Mouse binds (drag/resize) can't be run from a menu.
  if not opts.mouse then
    hd.binds[#hd.binds + 1] = {
      section = hd.section_name,
      keys = keys,
      description = description,
      action = action,
    }
  end
end

-- Run bind number i from the list. Called by keybinds_hint.sh via
-- `hyprctl eval 'hd.run_bind(i)'`.
function hd.run_bind(i)
  local bind = hd.binds[tonumber(i)]
  if not bind then return end
  if type(bind.action) == "function" then
    bind.action()
  else
    hl.dispatch(bind.action)
  end
end

-- Write the list to $XDG_RUNTIME_DIR as tab-separated
-- index, section, keys, description.
function hd.write_bind_list()
  local dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
  local path = dir .. "/hyprdots-binds" .. (hd.preview and "-preview" or "") .. ".tsv"
  local file = io.open(path, "w")
  if not file then return end
  for i, bind in ipairs(hd.binds) do
    local clean = function(s) return (tostring(s):gsub("[\t\n]", " ")) end
    file:write(i, "\t", clean(bind.section), "\t", clean(bind.keys), "\t", clean(bind.description), "\n")
  end
  file:close()
end
