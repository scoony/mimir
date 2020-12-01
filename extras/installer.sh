#!/bin/bash

remote_folder="https://raw.githubusercontent.com/scoony/mimir/master"
install_path="/opt/scripts"
main_user=`getent passwd "1000" | cut -d: -f1`
log_install="/home/$main_user/install-mimir.log"
log_install_echo="| tee -a $log_install"
my_printf="\r                                                                             "


## Check local language and apply MUI
os_language=$(locale | grep LANG | sed -n '1p' | cut -d= -f2 | cut -d_ -f1)
check_language=`curl -s "https://raw.githubusercontent.com/scoony/mimir/master/MUI/$os_language.lang"`
if [[ "$check_language" == "404: Not Found" ]]; then
  os_language="default"
fi
source <(curl -s https://raw.githubusercontent.com/scoony/mimir/master/MUI/$os_language.lang)


### make sure it's not the root account
rm "$log_install"
eval 'echo -e "\e[43m-------------------- $mui_installer_title --------------------\e[0m"' $log_install_echo
if [ "$(whoami)" == "root" ]; then
  eval 'echo -e "$mui_installer_fail"' $log_install_echo
  exit 1
fi

