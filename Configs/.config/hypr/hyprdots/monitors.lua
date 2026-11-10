-- Monitors. https://wiki.hypr.land/Configuring/Monitors/
-- Run `hyprctl monitors` to list output names.

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = hd.preview and 1 or "auto" })

-- Example:
-- hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1 })
