-- Startup programs. https://wiki.hypr.land/Configuring/Keywords/#executing

hl.on("hyprland.start", function()
  if hd.preview then
    -- Your real session already runs the bar, notifications, tray apps and
    -- wallpaper. Just open a terminal so there's something to look at.
    -- (No setcursor here either: it also writes the cursor to gsettings.)
    hl.exec_cmd(hd.terminal)
    return
  end

  -- Cursor for the compositor itself.
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 20")

  local s = hd.script
  hl.exec_cmd(s("resetxdgportal.sh")) -- reset XDPH for screenshare
  hl.exec_cmd("dbus-update-activation-environment --systemd --all") -- for XDPH
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd(s("polkitkdeauth.sh")) -- auth dialog for GUI apps
  hl.exec_cmd("waybar")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("udiskie --no-automount --smart-tray")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("dunst")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd(s("swwwallpaper.sh")) -- wallpaper daemon
  hl.exec_cmd(s("batterynotify.sh"))
  hl.exec_cmd("hypridle") -- dim, lock, screen off, suspend (hypridle.conf)

  -- GTK theme, icons, cursor and fonts (from themes/theme.conf and common.conf).
  -- Skipped in preview: gsettings is shared with your live session.
  local gs = "gsettings set org.gnome.desktop.interface "
  hl.exec_cmd(gs .. "icon-theme 'Tela-circle-dracula'")
  hl.exec_cmd(gs .. "gtk-theme 'Catppuccin-Mocha'")
  hl.exec_cmd(gs .. "color-scheme 'prefer-dark'")
  hl.exec_cmd(gs .. "cursor-theme 'Bibata-Modern-Ice'")
  hl.exec_cmd(gs .. "cursor-size 20")
  hl.exec_cmd(gs .. "font-name 'Cantarell 10'")
  hl.exec_cmd(gs .. "document-font-name 'Cantarell 10'")
  hl.exec_cmd(gs .. "monospace-font-name 'CaskaydiaCove Nerd Font Mono 9'")
  hl.exec_cmd(gs .. "font-antialiasing 'rgba'")
  hl.exec_cmd(gs .. "font-hinting 'full'")
end)
