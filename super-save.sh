#!/bin/bash




#### Tautulli (previously plexpy)
if [[ "$0" == "--restore" ]]; then
  mkdir -p "/opt/tautulli/backups"
else
  tautulli_path=`locate tautulli.db | sed '/mnt|home/d' | xargs dirname`
  
fi
