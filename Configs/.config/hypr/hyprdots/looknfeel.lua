-- HyprDots look: Catppuccin gradient borders, rounding and blur.
-- Ported from themes/theme.conf, themes/common.conf and userprefs.conf.

local active_border = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 }
local inactive_border = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 }

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 8,
    border_size = 2,
    layout = "dwindle",
    resize_on_border = true,

    col = {
      active_border = active_border,
      inactive_border = inactive_border,
    },
  },

  group = {
    col = {
      border_active = active_border,
      border_inactive = inactive_border,
      border_locked_active = active_border,
      border_locked_inactive = inactive_border,
    },
  },

  decoration = {
    rounding = 10,
    dim_special = 0.3,

    blur = {
      enabled = true,
      size = 6,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
      special = true,
    },

    shadow = {
      enabled = false,
    },
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    vrr = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },

  xwayland = {
    force_zero_scaling = true,
  },
})
