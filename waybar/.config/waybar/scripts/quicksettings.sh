#!/bin/bash

CHOICE=$(echo -e "Logout\nRestart\nShutdown\nSettings\nVolume Control" | wofi --dmenu --prompt "Quick Settings")

case $CHOICE in
  Logout) swaymsg exit ;;
  Restart) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
  Settings) gnome-control-center ;;
  "Volume Control") pavucontrol ;;
esac
