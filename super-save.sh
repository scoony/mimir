#!/bin/bash

########################
## Script de scoony
## Version: 0.0.0.0
########################
## Installation: 
## Micro-config
description="Sauvegarde automatique pour Ubuntu" #description pour le menu
script_github="" #emplacement du script original
icone_github="" #emplacement de l'icône du script
required_tools="git-core python2.7" #dépendances du script
script_cron="0 1 * * *" #définir la planification cron
########################






#### Tautulli (previously plexpy)
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
