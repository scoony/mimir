#!/bin/bash

requested: git-core python2.7



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
