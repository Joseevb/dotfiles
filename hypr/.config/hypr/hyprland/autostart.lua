return function(programs)
  hl.on("hyprland.start", function()
    local commands = {
      "hyprctl setcursor BreezeX-Black 28",
      programs.terminal,
      "caelestia shell -d & sleep 2 & hyprpaper",
      "vicinae server",
      "pkill swww-daemon; swww-daemon --format xrgb & sleep 0.5 && caelestia wallpaper ~/Pictures/Wallpapers/bg_img.png",
      "localsend --hidden",
      "hypridle",
      "~/.config/hypr/scripts/opencode-idle-inhibit.sh",
      "eval $(gnome-keyring-daemon --start); export SSH_AUTH_SOCK=$SSH_AUTH_SOCK",
      "kdeconnectd && kdeconnect-indicator",
      "wl-paste --type text --watch cliphist store",
      "wl-paste --type image --watch cliphist store",
      "systemctl --user start hyprpolkitagent",
      "tpm-fido",
      "/usr/bin/hyprland-per-window-layout",
      "/usr/lib/kdeconnectd",
      "~/.local/bin/agent-idle-inhibit.sh",
      "sleep 10 && bitwarden-desktop",
    }

    for _, command in ipairs(commands) do
      hl.exec_cmd(command)
    end
  end)
end
