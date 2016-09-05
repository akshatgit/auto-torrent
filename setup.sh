install_dependacies()
{
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' transmission-daemon | grep "install ok installed")
  echo Checking for Transmission Client: $PKG_OK
  if [ -z "$PKG_OK" ]; then
    echo "Installing transmission-daemon transmission-cli transmission-common"
    sudo add-apt-repository ppa:transmissionbt/ppa
    sudo apt-get update
    sudo apt-get install transmission-cli transmission-common transmission-daemon
  else
    echo "Transmission Already installed"
  fi
  PKG_OK2=$(dpkg-query -W --showformat='${Status}\n' jq | grep "install ok installed")
  echo Checking for JQ: $PKG_OK2
  if [ -z "$PKG_OK2" ]; then
    echo "Installing jq..."
    sudo apt-get install jq
  else
    echo "JQ Already Installed"
  fi
}
check_valid_username()
{
  if [ -z "$1" ]]; then
    echo "Enter a valid Username"
    read var
    check_valid_username $var
  else
    echo "Username :$1"
  fi
}
check_valid_password()
{
  if [ -z "$1" ]; then
    echo "Enter a valid Password"
    read pass;
    check_valid_password $pass
  else
    echo "Password :$1"
  fi
}
creating_user()
{
  sudo cat /var/lib/transmission-daemon/info/settings.json |
  sudo jq 'to_entries |
       map(if .key == "rpc-username"
          then . + {"value":"'$1'"}
          elif .key == "rpc-password"
          then . + {"value":"'$2'"}
          elif .key == "umask"
          then . + {"value":2}
          else .
          end
         ) |
      from_entries' > sudo /var/lib/transmission-daemon/info/settings.json
}
install_dependacies
echo "Creating a new user...."
echo "Enter a Username"
read var
check_valid_username $var
echo "Enter a Password"
read pass
check_valid_password $pass
echo "Stopping the Transmission Daemon"
sudo service transmission-daemon stop
creating_user $var $pass
echo "User created"
sudo service transmission-daemon start
