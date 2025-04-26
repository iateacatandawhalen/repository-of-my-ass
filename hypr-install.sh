#!/usr/bin/env bash
set -e

# 1) Install deps via yay (will pull from both official repos and AUR)
if command -v yay &>/dev/null; then
  yay -S --needed \
    hyprland waybar alacritty rofi grim slurp pamixer swaybg picom pywal xorg-xwayland
else
  echo "Error: yay not found. Please install yay and re-run this script."
  exit 1
fi

# 2) Create config directories & screenshot/wallpaper dirs
HYPR="$HOME/.config/hypr"
WAYBAR="$HOME/.config/waybar"
PICOM="$HOME/.config/picom"
mkdir -p "$HYPR" "$WAYBAR" "$PICOM" \
         "$HOME/Pictures/Screenshots" \
         "$HOME/Pictures/Wallpapers"

# 3) Default colours
cat > "$HYPR/colors.conf" <<'EOF'
BORDER='#333333ff'
BG='#282a36ff'
FG='#f8f8f2ff'
ACCENT='#6272a4ff'
EOF

# 4) Hyprland template
cat > "$HYPR/hyprland.conf.template" <<'EOF'
# ─── General ─────────────────────────────────────────
general {
    decoration_border_size = 2
    decoration_border_radius = 4
    decoration_border_color = ${BORDER}
    window_gap = 8
    exec-once = swaybg -m fill /usr/share/backgrounds/archlinux/arch-wallpaper.jpg
}

# ─── Bar (Waybar) ─────────────────────────────────────
bar {
    position = top
    height = 30
    modules-left = workspaces
    modules-center = windowtitle
    modules-right = pulseaudio, battery, cpu, memory, network, clock
}

# ─── Floating ─────────────────────────────────────────
windowrule = float, class:Firefox
windowrule = float, class:mpv
windowrule = float, class:Pinentry

# ─── Input ────────────────────────────────────────────
mousebind = SUPER, 1, move
mousebind = SUPER, 3, resize

# ─── Keybinds ─────────────────────────────────────────
bind = SUPER + RETURN, exec, alacritty
bind = SUPER + D,       exec, rofi -show drun
bind = SUPER + Q,       killactive
bind = SUPER + ESC,     reload
bind = SUPER + SHIFT + ESC, kill, Hyprland ; exec Hyprland

bind = SUPER + F11,     fullscreen
bind = SUPER + F,       togglefloating

bind = SUPER + {1..9}, workspace, number {1..9}
bind = SUPER + SHIFT + {1..9}, movetoworkspace, number {1..9}

bind = SUPER + H, focusleft
bind = SUPER + J, focusdown
bind = SUPER + K, focusup
bind = SUPER + L, focusright

bind = SUPER + SHIFT + H, moveactivepixel, -20 0
bind = SUPER + SHIFT + J, moveactivepixel, 0 20
bind = SUPER + SHIFT + K, moveactivepixel, 0 -20
bind = SUPER + SHIFT + L, moveactivepixel, 20 0

bind = SUPER + ALT + H, resizeactivepixel, -20 0
bind = SUPER + ALT + J, resizeactivepixel, 0 20
bind = SUPER + ALT + K, resizeactivepixel, 0 -20
bind = SUPER + ALT + L, resizeactivepixel, 20 0

bind = XF86AudioRaiseVolume, exec, pamixer --increase 5
bind = XF86AudioLowerVolume, exec, pamixer --decrease 5
bind = XF86AudioMute,        exec, pamixer --toggle-mute

bind = PRINT, exec, grim ~/Pictures/Screenshots/$(date +%F_%T).png && notify-send "Screenshot"
bind = SUPER + SHIFT + PRINT, exec, \
  slurp | grim -g - ~/Pictures/Screenshots/$(date +%F_%T).png && notify-send "Area shot"

# theme toggle
bind = SUPER + T, exec, "$HYPR/apply_theme.sh" ~/Pictures/Wallpapers/current.jpg
EOF

# 5) Theme-apply script
cat > "$HYPR/apply_theme.sh" <<'EOF'
#!/usr/bin/env bash
# Usage: apply_theme.sh /path/to/wallpaper.jpg

wal -i "$1"
source ~/.cache/wal/colors.sh

cat > ~/.config/hypr/colors.conf <<EOC
BORDER='${color0}ff'
BG='${background}ff'
FG='${foreground}ff'
ACCENT='${color2}ff'
EOC

envsubst < ~/.config/hypr/hyprland.conf.template > ~/.config/hypr/hyprland.conf
hyprctl reload

killall picom
picom --config ~/.config/picom/picom.conf -b

killall -SIGUSR1 waybar
EOF
chmod +x "$HYPR/apply_theme.sh"

# 6) Waybar config
cat > "$WAYBAR/config" <<'EOF'
{
  "layer": "top",
  "position": "top",
  "modules-left": ["workspaces"],
  "modules-center": ["custom/windowtitle"],
  "modules-right": ["pulseaudio", "battery", "cpu", "memory", "network", "clock"],
  "custom/windowtitle": {
    "exec": "hyprctl activewindow | awk -F': ' '/Class:/{print \$2}'",
    "interval": 1
  },
  "clock": { "format": "%Y-%m-%d %H:%M" },
  "battery": { "format": "{capacity}% ({status})", "interval": 30 },
  "cpu":     { "format": "CPU {usage}%",      "interval": 2 },
  "memory":  { "format": "RAM {used}/{total} GB", "interval": 5 },
  "network": { "format": "{ifname}: {ipaddr}",  "interface": "wlan0", "interval": 10 },
  "pulseaudio": { "format": "{icon} {volume}%", "interval": 1 }
}
EOF

# 7) Default Waybar CSS (overridden by pywal link)
cat > "$WAYBAR/style.css" <<'EOF'
:root {
  --bg: #282a36;
  --fg: #f8f8f2;
  --accent: #6272a4;
  --border: #333333;
}
* {
  font-family: "Iosevka", sans-serif;
  font-size: 10pt;
  color: var(--fg);
  background: var(--bg);
}
#workspaces button { padding: 0 10px; }
#workspaces button.focused { background: var(--border); color: var(--accent); }
#battery,#cpu,#memory,#network,#pulseaudio,#clock { margin: 0 8px; }
#custom-windowtitle { text-align: center; width: 200px; overflow: hidden; text-overflow: ellipsis; }
EOF

# 8) Symlink pywal CSS
ln -sf ~/.cache/wal/colors.css "$WAYBAR/style.css"

# 9) Default picom.conf
cat > "$PICOM/picom.conf" <<'EOF'
backend = "glx"
vsync = true
shadow = true
shadow-radius = 7
shadow-offset-x = -7
shadow-offset-y = -7
shadow-opacity = 0.30
fade-in-step = 0.03
fade-out-step = 0.03
opacity-rule = [
  "90:class_g = 'Alacritty'",
  "85:class_g = 'Waybar'"
];
EOF

# 10) Initial theme apply (if wallpaper exists)
if [ -f "$HOME/Pictures/Wallpapers/current.jpg" ]; then
  "$HYPR/apply_theme.sh" "$HOME/Pictures/Wallpapers/current.jpg"
else
  echo "Warning: No wallpaper at ~/Pictures/Wallpapers/current.jpg; initial theme apply skipped."
fi

echo "Setup complete. Drop a wallpaper at ~/Pictures/Wallpapers/current.jpg and press SUPER+T in Hyprland."