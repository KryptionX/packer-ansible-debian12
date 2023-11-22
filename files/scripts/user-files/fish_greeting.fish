function fish_greeting
  status --is-login
  if [ $status != 0 ]
    cat /etc/motd
  end
end
