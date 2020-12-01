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

my_title_count=`echo -n "$mui_installer_title" | sed "s/\\\e\[[0-9]\{1,2\}m//g" | wc -c`
line_lengh="78"
before_count=$((($line_lengh-$my_title_count)/2))
after_count=$(((($line_lengh-$my_title_count)%2)+$before_count))
before=`eval printf "%0.s-" {1..$before_count}`
after=`eval printf "%0.s-" {1..$after_count}`
eval 'printf "\e[43m%s%s%s\e[0m\n" "$before" "$mui_installer_title" "$after"' $log_install_echo
if [ "$(whoami)" != "root" ]; then
  eval 'echo -e "$mui_installer_fail"' $log_install_echo
  end_of_script=`date`
  source <(curl -s https://raw.githubusercontent.com/scoony/mimir/master/MUI/$os_language.lang)
  my_title_count=`echo -n "$mui_end_of_script" | sed "s/\\\e\[[0-9]\{1,2\}m//g" | sed 's/é/e/g' | wc -c`
  line_lengh="78"
  before_count=$((($line_lengh-$my_title_count)/2))
  after_count=$(((($line_lengh-$my_title_count)%2)+$before_count))
  before=`eval printf "%0.s-" {1..$before_count}`
  after=`eval printf "%0.s-" {1..$after_count}`
  eval 'printf "\e[43m%s%s%s\e[0m\n" "$before" "$mui_end_of_script" "$after"' $log_install_echo
  exit 1
fi


## download mimir.sh

eval 'printf  "\e[44m\u2263\u2263\u2263 \e[0m \e[44m \e[1m %-62s  \e[0m \e[44m  \e[0m \e[44m \e[0m \e[34m\u2759\e[0m\n" "$mui_section_script"' $log_install_echo
wget -q "$remote_folder/mimir.sh" -O "$install_path/mimir.sh" && sed -i -e 's/\r//g' "$install_path/mimir.sh" && chmod +x "$install_path/mimir.sh" >> $log_install &
pid=$!
spin='-\|/'
i=0
while kill -0 $pid 2>/dev/null; do
  i=$(( (i+1) %4 ))
  printf "\r[  ] $mui_installer_wget mimir.sh ... ${spin:$i:1}" 
  sleep .1
done
printf "$my_printf" && printf "\r"
eval 'echo -e "[\e[42m\u2713 \e[0m] $mui_installer_wget mimir.sh"' $mon_log_perso


## download language files

eval 'printf  "\e[44m\u2263\u2263\u2263 \e[0m \e[44m \e[1m %-62s  \e[0m \e[44m  \e[0m \e[44m \e[0m \e[34m\u2759\e[0m\n" "$mui_section_lang"' $log_install_echo
if [[ ! -d "/root/.config/mimir/MUI" ]]; then mkdir -p "/root/.config/mimir/MUI"; fi
wget -q "$remote_folder/MUI/default.lang" -O "/root/.config/mimir/MUI/default.lang" && sed -i -e 's/\r//g' "/root/.config/mimir/MUI/default.lang" && chmod +x "/root/.config/mimir/MUI/default.lang" >> $log_install &
pid=$!
spin='-\|/'
i=0
while kill -0 $pid 2>/dev/null; do
  i=$(( (i+1) %4 ))
  printf "\r[  ] $mui_installer_wget MUI/default.lang ... ${spin:$i:1}" 
  sleep .1
done
printf "$my_printf" && printf "\r"
eval 'echo -e "[\e[42m\u2713 \e[0m] $mui_installer_wget MUI/default.lang"' $log_install_echo
if [[ "$os_language" != "default" ]]; then 
  wget -q "$remote_folder/MUI/$os_language.lang" -O "/root/.config/mimir/MUI/$os_language.lang" && sed -i -e 's/\r//g' "/root/.config/mimir/MUI/$os_language.lang" && chmod +x "/root/.config/mimir/MUI/$os_language.lang" >> $log_install &
  pid=$!
  spin='-\|/'
  i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r[  ] $mui_installer_wget MUI/$os_language.lang ... ${spin:$i:1}" 
    sleep .1
  done
  printf "$my_printf" && printf "\r"
  eval 'echo -e "[\e[42m\u2713 \e[0m] $mui_installer_wget MUI/$os_language.lang"' $log_install_echo
fi
my_language_file="/root/.config/mimir/MUI/$os_language.lang"


## download modules

eval 'printf  "\e[44m\u2263\u2263\u2263 \e[0m \e[44m \e[1m %-62s  \e[0m \e[44m  \e[0m \e[44m \e[0m \e[34m\u2759\e[0m\n" "$mui_section_modules"' $log_install_echo
source <(curl -s https://raw.githubusercontent.com/scoony/mimir/master/extras/update-files)
if [[ ! -d "/root/.config/mimir/modules" ]]; then mkdir -p "/root/.config/mimir/modules"; fi
  for current_file in $file{001..999}; do
    wget --quiet "${remote_folder}/modules/${current_file}" -O "/root/.config/mimir/modules/${current_file}" && sed -i -e 's/\r//g' "/root/.config/mimir/modules/${current_file}" && chmod +x "/root/.config/mimir/modules/${current_file}" >> $log_install &
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
      i=$(( (i+1) %4 ))
      printf "\r[  ] $mui_installer_wget modules/${current_file} ... ${spin:$i:1}" 
      sleep .1
    done
    printf "$my_printf" && printf "\r"
    eval 'echo -e "[\e[42m\u2713 \e[0m] $mui_installer_wget modules/${current_file}"' $log_install_echo
  done


## end of script

end_of_script=`date`
source $my_language_file
my_title_count=`echo -n "$mui_end_of_script" | sed "s/\\\e\[[0-9]\{1,2\}m//g" | sed 's/é/e/g' | wc -c`
line_lengh="78"
before_count=$((($line_lengh-$my_title_count)/2))
after_count=$(((($line_lengh-$my_title_count)%2)+$before_count))
before=`eval printf "%0.s-" {1..$before_count}`
after=`eval printf "%0.s-" {1..$after_count}`
eval 'printf "\e[43m%s%s%s\e[0m\n" "$before" "$mui_end_of_script" "$after"' $log_install_echo
