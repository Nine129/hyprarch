choice=$(printf "Lock\nSleep\nLogout\nReboot\nShutdown" \
  | fuzzel --dmenu \
    --prompt " " \
    --lines 5 \
    --width 15 \
    --hide-prompt \
  )

case "$choice" in
  Lock)     hyprlock ;;
  Sleep)    systemctl suspend ;;
  Logout)   hyprctl dispatch exit ;;
  Reboot)   systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
