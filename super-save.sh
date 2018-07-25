#!/bin/bash

########################
## Script de scoony
## Version: 0.0.0.0
########################
## Installation: 
## Micro-config
description_fr="Sauvegarde/restauration automatique pour Linux" #description pour le menu
description_eng="Automatically backup/restore for Linux"
script_github="" #emplacement du script original
icone_github="" #emplacement de l'icône du script
langue_fr=""
langue_eng=""
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




#### Tautulli (anciennement plexpy)
if [[ "$1" == "--restore" ]]; then
  if [[ -d "/mnt/save/..." ]]; then
    if [[ "$2" != "-y" ]]; then
      printf "Do you want to restore/install Tautulli? (yes/no) : "
      read question_tautulli
    else
      question_tautulli="yes"
    fi
    if [[ "${question_tautulli,,}" == "yes|y" ]]; then
      if [[ -d "/opt/Tautulli" ]]; then
        cp /mnt/save...
      else
        cd /opt
        git clone https://github.com/Tautulli/Tautulli.git
        adduser --system --no-create-home tautulli
        chown tautulli:nogroup -R /opt/Tautulli
        touch /etc/default/tautulli
        ## mettre les params dans le fichier
        chmod +x /opt/Tautulli/init-scripts/init.ubuntu
        cp /opt/Tautulli/init-scripts/init.ubuntu /etc/init.d/tautulli
        update-rc.d tautulli defaults
        cp /mnt/save...
        service tautulli start
      fi
    fi
  fi
else
  tautulli_path=`locate tautulli.db | sed '/mnt|home/d' | xargs dirname`
  if [[ "$tautulli_path" != "" ]]; then
    printf "[\e[42m  \e[0m] Tautulli detected\n"
    printf "     -- path: $tautulli_path\n"
    mkdir -p "/mnt/save/..."
    cd "$tautulli_path/backups"
    cp *.* "/mnt/save/..."
    cat /etc/default/tautulli > /mnt/save/...
  fi
fi
