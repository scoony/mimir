#!/bin/bash

########################
## Script de scoony
## Version: 0.0.0.0
########################
## Installation: 
## Micro-config
description_fr="Sauvegarde/restauration automatique pour Linux" #description pour le menu
description_eng="Automatically backup/restore for Linux"
script_github="https://raw.githubusercontent.com/scoony/mimir.sh/master/mimir.sh" #empoacement du script original
icone_github="" #emplacement de l'icône du script
langue_fr="https://raw.githubusercontent.com/scoony/mimir.sh/master/.cache-languages/mimir.french"
langue_eng="https://raw.githubusercontent.com/scoony/mimir.sh/master/.cache-languages/mimir.english"
required_repos="" #ajout de repository
required_tools="git-core python2.7" #dépendances du script
script_cron="0 1 * * *" #définir la planification cron
########################

#### Vérification de la langue du system
if [[ "$@" =~ "--langue=FR" ]] || [[ "$@" =~ "--langue=ENG" ]]; then
  if [[ "$@" =~ "--langue=FR" ]]; then
    affichage_langue="french"
  else
    affichage_langue="english"
  fi
else
  os_langue=$(locale | grep LANG | sed -n '1p' | cut -d= -f2 | cut -d_ -f1)
  if [[ "$os_langue" == "fr" ]]; then
    affichage_langue="french"
  else
    affichage_langue="english"
  fi
fi

#### Déduction des noms des fichiers (pour un portage facile)
mon_script_fichier=`basename "$0"`
mon_script_base=`echo ''$mon_script_fichier | cut -f1 -d'.'''`
mon_script_base_maj=`echo ${mon_script_base^^}`
mon_script_config=`echo "/root/.config/"$mon_script_base"/"$mon_script_base".conf"`
mon_script_ini=`echo "/root/.config/"$mon_script_base"/"$mon_script_base".ini"`
mon_script_langue=`echo "/root/.config/"$mon_script_base"/"$affichage_langue".lang"`
mon_script_log=`echo $mon_script_base".log"`
mon_script_desktop=`echo $mon_script_base".desktop"`
mon_script_updater=`echo $mon_script_base"-update.sh"`
 
#### Chargement du fichier pour la langue (ou installation)
if [[ "$affichage_langue" == "french" ]]; then
  langue_distant_check=`wget -q -O- "$langue_fr" | sed 's/\r//g' | wc -c`
##  echo "Langue: FR"
##  echo "Distant: "$langue_distant_check
else
  langue_distant_check=`wget -q -O- "$langue_eng" | sed 's/\r//g' | wc -c`
##  echo "Langue: ENG"
##  echo "Distant: "$langue_distant_check
fi
langue_local_check=`cat "$mon_script_langue" 2>/dev/null | wc -c`
##echo "Local: "$langue_local_check
if [[ "$langue_distant_check" != "$langue_local_check" ]]; then
  if [[ "$affichage_langue" == "french" ]]; then
    echo "mise à jour du fichier de language disponible"
    echo "téléchargement de la mise à jour et installation..."
    wget -q "$langue_fr" -O "$mon_script_langue"
    sed -i -e 's/\r//g' $mon_script_langue
  else
    echo "language file update available"
    echo "downloading and applying update..."
    wget -q "$langue_eng" -O "$mon_script_langue"
    sed -i -e 's/\r//g' $mon_script_langue
  fi
fi
source $mon_script_langue

#### Vérification que le script possède les droits root
## NE PAS TOUCHER
if [[ "$EUID" != "0" ]]; then
  if [[ "$CRON_SCRIPT" == "oui" ]]; then
    exit 1
  else
    if [[ "$CHECK_MUI" != "" ]]; then
      source $mon_script_langue
      echo "$mui_root_check"
    else
      echo "Vous devrez impérativement utiliser le compte root"
    fi
    exit 1
  fi
fi

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
      if [[ "$CHECK_MUI" != "" ]]; then
        source $mon_script_langue
        echo $process_important"$mui_prevent_dupe_task"
      else
        echo $process_important" est en cours de fonctionnement, arrêt du script"
      fi
      fin_script=`date`
      if [[ "$CHECK_MUI" != "" ]]; then
        source $mon_script_langue
        echo -e "$mui_end_of_script"
      else
        if [[ "$CHECK_MUI" != "" ]]; then
          source $mon_script_langue
          echo -e "$mui_end_of_script"
        else
          echo -e "\e[43m -- FIN DE SCRIPT: $fin_script -- \e[0m "
        fi
      fi
    fi
    exit 1
  fi
done









#### MOTD du SSH
cd /etc/update-motd.d
custom_motd=`ls -I 00-header -I 10-help-text -I 50-motd-news -I 80-esm -I 80-livepatch -I 90-updates-available -I 91-release-upgrade -I 95-hwe-eol -I 98-fsck-at-reboot -I 98-reboot-required`

