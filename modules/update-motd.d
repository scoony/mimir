#### MOTD du SSH
cd /etc/update-motd.d
custom_motd=`ls -I 00-header -I 10-help-text -I 50-motd-news -I 80-esm -I 80-livepatch -I 90-updates-available -I 91-release-upgrade -I 95-hwe-eol -I 98-fsck-at-reboot -I 98-reboot-required`
