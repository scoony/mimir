#!/bin/bash

########################
## Script de scoony
## Version: 0.0.0.0
########################
## Installation: 
## Micro-config
description_fr="Sauvegarde/restauration automatique pour Linux" #description pour le menu
description_eng="Automatically backup/restore for Linux"
script_github="https://raw.githubusercontent.com/scoony/mimir/master/mimir.sh" #empoacement du script original
icone_github="" #emplacement de l'icône du script
required_repos="" #ajout de repository
required_tools="git-core python2.7" #dépendances du script
script_cron="0 1 * * *" #définir la planification cron
verification_process=""
########################


#### Vérification de la langue du system
if [[ "$@" =~ "--langue=" ]]; then
  affichage_langue=`echo "$@" | sed 's/.*--langue=//' | sed 's/ .*//' | tr '[:upper:]' '[:lower:]'`
else
  affichage_langue=$(locale | grep LANG | sed -n '1p' | cut -d= -f2 | cut -d_ -f1)
fi
verif_langue=`curl -s "https://raw.githubusercontent.com/scoony/mimir/master/MUI/$affichage_langue.lang"`
if [[ "$verif_langue" == "404: Not Found" ]]; then
  affichage_langue="default"
fi


#### Déduction des noms des fichiers (pour un portage facile)
mon_script_fichier=`basename "$0"`
mon_script_base=`echo ''$mon_script_fichier | cut -f1 -d'.'''`
mon_script_base_maj=`echo ${mon_script_base^^}`
mon_script_modules=`echo "/root/.config/"$mon_script_base"/modules"`
mon_script_config=`echo "/root/.config/"$mon_script_base"/"$mon_script_base".conf"`
mon_script_ini=`echo "/root/.config/"$mon_script_base"/"$mon_script_base".ini"`
mon_script_langue=`echo "/root/.config/"$mon_script_base"/MUI/"$affichage_langue".lang"`
mon_script_log=`echo $mon_script_base".log"`
mon_script_desktop=`echo $mon_script_base".desktop"`
mon_script_updater=`echo $mon_script_base"-update.sh"`


#### Vérification que le script possède les droits root
## NE PAS TOUCHER
if [ "$(whoami)" != "root" ]; then
  if [[ "$CRON_SCRIPT" == "oui" ]]; then
    exit 1
  else
    source <(curl -s https://raw.githubusercontent.com/scoony/mimir/master/MUI/$affichage_langue.lang)
    echo "$mui_root_check"
    exit 1
  fi
fi


#### Chargement du fichier pour la langue (ou installation)
if [[ -f "$mon_script_langue" ]]; then
  distant_md5=`curl -s "https://raw.githubusercontent.com/scoony/mimir/master/MUI/$affichage_langue.lang" | md5sum | cut -f1 -d" "`
  local_md5=`md5sum "$mon_script_langue" 2>/dev/null | cut -f1 -d" "`
  if [[ $distant_md5 != $local_md5 ]]; then
    wget --quiet "https://raw.githubusercontent.com/scoony/mimir/master/MUI/$affichage_langue.lang" -O "$mon_script_langue"
    chmod +x "$mon_script_langue"
  fi
else
  wget --quiet "https://raw.githubusercontent.com/scoony/mimir/master/MUI/$affichage_langue.lang" -O "$mon_script_langue"
  chmod +x "$mon_script_langue"
fi
source $mon_script_langue


#### Fonction pour envoyer des push
push-message() {
  push_title=$1
  push_content=$2
  for user in {1..10}; do
    destinataire=`eval echo "\\$destinataire_"$user`
    if [ -n "$destinataire" ]; then
      curl -s \
        --form-string "token=$token_app" \
        --form-string "user=$destinataire" \
        --form-string "title=$push_title" \
        --form-string "message=$push_content" \
        --form-string "html=1" \
        --form-string "priority=0" \
        https://api.pushover.net/1/messages.json > /dev/null
    fi
  done
}


#### Vérification de process pour éviter les doublons (commandes externes)
for process_travail in $verification_process ; do
  process_important=`ps aux | grep $process_travail | sed '/grep/d'`
  if [[ "$process_important" != "" ]] ; then
    if [[ "$CRON_SCRIPT" != "oui" ]] ; then
      echo "$process_travail $mui_prevent_dupe_task"
      end_of_script=`date`
      source $mon_script_langue
      my_title_count=`echo -n "$mui_end_of_script" | sed "s/\\\e\[[0-9]\{1,2\}m//g" | sed 's/é/e/g' | wc -c`
      line_lengh="78"
      before_count=$((($line_lengh-$my_title_count)/2))
      after_count=$(((($line_lengh-$my_title_count)%2)+$before_count))
      before=`eval printf "%0.s-" {1..$before_count}`
      after=`eval printf "%0.s-" {1..$after_count}`
      printf "\e[43m%s%s%s\e[0m\n" "$before" "$mui_end_of_script" "$after"
    fi
    exit 1
  fi
done


## Traitement des modules
mes_modules=`ls $mon_script_modules`
if [[ "$mes_modules" == "" ]]; then
  echo "Aucun module détecté"
else
  for module in $mes_modules ; do
    module_name=`basename $module`
    if [[ -d "/etc/$module_name" ]] || [[ -d "/opt/$module_name" ]]; then
      echo "Module detecte (restore): ["$module_name"]"
      #bash "$module" --restore
    else
      echo "Module detecte (install): ["$module_name"]"
      #bash "$module" --install
    fi
  done
fi


## fin du script
end_of_script=`date`
source $mon_script_langue
my_title_count=`echo -n "$mui_end_of_script" | sed "s/\\\e\[[0-9]\{1,2\}m//g" | sed 's/é/e/g' | wc -c`
line_lengh="78"
before_count=$((($line_lengh-$my_title_count)/2))
after_count=$(((($line_lengh-$my_title_count)%2)+$before_count))
before=`eval printf "%0.s-" {1..$before_count}`
after=`eval printf "%0.s-" {1..$after_count}`
printf "\e[43m%s%s%s\e[0m\n" "$before" "$mui_end_of_script" "$after"
