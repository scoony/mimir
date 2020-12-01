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


### create log install file and permissions
if [ "$(whoami)" == "root" ]; then
  if [[ -f "$log_install" ]]; then
    rm "$log_install"
  fi
  touch "$log_install"
  chmod 777 -R "$log_install"
  chown $main_user:$main_user "$log_install"
fi


### make sure it's not the root account
eval 'echo -e "\e[43m-------------------- $mui_installer_title --------------------\e[0m"' $log_install_echo
if [ "$(whoami)" != "root" ]; then
  eval 'echo -e "$mui_installer_fail"' $log_install_echo
  exit 1
fi


## download files
wget -q "$remote_folder/mimir.sh" -O "$install_path/mimir.sh" && chmod +x "$install_path/mimir.sh" >> $log_install &
pid=$!
spin='-\|/'
i=0
while kill -0 $pid 2>/dev/null; do
  i=$(( (i+1) %4 ))
  printf "\r[  ] $mui_installer_wget mimir.sh ... ${spin:$i:1}" 
  sleep .1
done
if [[ ! -d "/root/.config/mimir/MUI" ]]; then mkdir -p "/root/.config/mimir/MUI"; fi
wget -q "$remote_folder/MUI/$os_language.lang" -O "/root/.config/mimir/MUI/$os_language.lang" >> $log_install &
pid=$!
spin='-\|/'
i=0
while kill -0 $pid 2>/dev/null; do
  i=$(( (i+1) %4 ))
  printf "\r[  ] $mui_installer_wget MUI/$os_language.lang ... ${spin:$i:1}" 
  sleep .1
done
printf "$my_printf" && printf "\r"
eval 'echo -e "[\e[42m\u2713 \e[0m] $mui_installer_wget_done"' $log_install_echo
