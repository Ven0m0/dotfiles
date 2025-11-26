run_menu(){
  local -a opts=("Lock" "Logout" "Reboot" "Poweroff"); local choice
  # Pass array elements as newlines to menu
  # mapfile reads result back into 'choice' strictly
  choice=$(printf "%s\n" "${opts[@]}" | _menu "System:")
  # Fast string matching
  case "${choice,,}" in # ,, = lowercase
    lock) loginctl lock-session ;;
    logout) loginctl terminate-user "$USER" ;;
    reboot) systemctl reboot ;;
    poweroff) systemctl poweroff ;;
    *) : ;; # Ignore cancel/empty
  esac
}
run_menu
