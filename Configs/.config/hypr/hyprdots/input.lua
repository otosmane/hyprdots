-- Input, gestures and per-device settings.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = 0,
    force_no_accel = true,
    numlock_by_default = true,

    touchpad = {
      natural_scroll = false,
    },
  },
})

-- 3-finger horizontal swipe switches workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device override.
hl.device({ name = "epic mouse V1", sensitivity = -0.5 })
