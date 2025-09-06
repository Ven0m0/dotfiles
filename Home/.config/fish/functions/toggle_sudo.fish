function toggle_sudo
  if test (commandline) = ""
    commandline (history --max=1 | string trim)
  end
  if string match -q "sudo *" -- (commandline)
    # Remove sudo
    set cmd (string replace -r '^sudo\s+' '' -- (commandline))
    commandline -- $cmd
  else
    # Prepend sudo
    commandline -- sudo (commandline)
  end
end
