-- Window and layer rules, ported from windowrules.conf.
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

local function opacity(value, classes)
  for _, class in ipairs(classes) do
    hl.window_rule({ match = { class = "^(" .. class .. ")$" }, opacity = value })
  end
end

local function float(classes)
  for _, class in ipairs(classes) do
    hl.window_rule({ match = { class = "^(" .. class .. ")$" }, float = true })
  end
end

-- Opacity
opacity("0.90 0.90", {
  "firefox", "Google-chrome", "Brave-browser",
  "com.github.rafostar.Clapper",
})
opacity("0.80 0.80", {
  "code-oss", "[Cc]ode", "code-url-handler", "code-insiders-url-handler",
  "kitty", "foot", "org.kde.dolphin", "org.kde.ark",
  "nwg-look", "qt5ct", "qt6ct", "kvantummanager",
  "com.github.tchx84.Flatseal", "hu.kramo.Cartridges", "com.obsproject.Studio",
  "gnome-boxes", "vesktop", "discord", "WebCord", "ArmCord", "app.drey.Warp",
  "net.davidotek.pupgui2", "yad", "Signal", "io.github.alainm23.planify",
  "io.gitlab.theevilskeleton.Upscaler", "com.github.unrud.VideoDownloader",
  "io.gitlab.adhami3310.Impression", "io.missioncenter.MissionCenter",
  "io.github.flattool.Warehouse",
})
opacity("0.80 0.70", {
  "org.pulseaudio.pavucontrol", "blueman-manager", "nm-applet", "nm-connection-editor",
  "org.kde.polkit-kde-authentication-agent-1", "polkit-gnome-authentication-agent-1",
  "org.freedesktop.impl.portal.desktop.gtk", "org.freedesktop.impl.portal.desktop.hyprland",
})
opacity("0.70 0.70", { "[Ss]team", "steamwebhelper", "[Ss]potify" })
hl.window_rule({ match = { initial_title = "^(Spotify Free)$" }, opacity = "0.70 0.70" })
hl.window_rule({ match = { initial_title = "^(Spotify Premium)$" }, opacity = "0.70 0.70" })

-- Floating
float({
  "vlc", "kvantummanager", "qt5ct", "qt6ct", "nwg-look", "org.kde.ark",
  "org.pulseaudio.pavucontrol", "blueman-manager", "nm-applet", "nm-connection-editor",
  "org.kde.polkit-kde-authentication-agent-1",
  "Signal", "com.github.rafostar.Clapper", "app.drey.Warp", "net.davidotek.pupgui2",
  "yad", "eog", "io.github.alainm23.planify", "io.gitlab.theevilskeleton.Upscaler",
  "com.github.unrud.VideoDownloader", "io.gitlab.adhami3310.Impression",
  "io.missioncenter.MissionCenter", "xdg-desktop-portal-gtk",
})

local float_class_title = {
  { "org.kde.dolphin", "Progress Dialog — Dolphin" },
  { "org.kde.dolphin", "Copying — Dolphin" },
  { "firefox", "Picture-in-Picture" },
  { "firefox", "Library" },
  { "kitty", "top" },
  { "kitty", "btop" },
  { "kitty", "htop" },
}
for _, rule in ipairs(float_class_title) do
  hl.window_rule({ match = { class = "^(" .. rule[1] .. ")$", title = "^(" .. rule[2] .. ")$" }, float = true })
end

-- Common dialogs
for _, title in ipairs({
  "About Mozilla Firefox", "Open", "Choose Files", "Save As",
  "Confirm to replace files", "File Operation Progress",
}) do
  hl.window_rule({ match = { title = "^(" .. title .. ")$" }, float = true })
end

-- Layer rules: blur behind the bar, launcher, notifications and logout menu.
for _, namespace in ipairs({
  "waybar", "rofi", "notifications", "swaync-notification-window",
  "swaync-control-center", "logout_dialog",
}) do
  hl.layer_rule({ match = { namespace = namespace }, blur = true, ignore_alpha = 0 })
end
