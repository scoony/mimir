#!/bin/bash

requested: git-core



#### Tautulli (previously plexpy)
if [[ "$1" == "--restore" ]]; then
  if [[ -d "/mnt/save/..." ]]; then
    printf "Do you want to restore/install Tautulli? (yes/no) : "
    read question_tautulli
    if [[ "${question_tautulli,,}" == "yes|y" ]]; then
      if [[ -d "/opt/Tautulli" ]]; then
        cp /mnt/save...
      else
        cd /opt
        git clone https://github.com/Tautulli/Tautulli.git
        adduser --system --no-create-home tautulli
        chown tautulli:nogroup -R /opt/Tautulli
        touch /etc/default/tautulli
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
    mkdir -p "/mnt/save/..."
    cd "$tautulli_path/backups"
    cp *.* "/mnt/save/..."
  fi
fi
