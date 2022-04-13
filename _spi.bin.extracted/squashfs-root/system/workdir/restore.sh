#!/bin/sh

ROOT=$PWD

. ./evn.sh

ralink_init clear 2860

cd /vendor/user
if [ -f "./userrestore.sh" ]; then  
. ./userrestore.sh
fi

rm -rf /vendor/download
rm -rf /vendor/downloadorg
rm -rf /mnt/keymap.xml
rm -rf /mnt/totalqueue.xml
rm -rf /mnt/.queue.init
rm -rf /mnt/defualt_ssid_mcu
rm -rf /mnt/RecentlyQueue.xml
rm -rf /mnt/FavouriteQueue.xml
rm -rf /vendor/wiimu
rm -rf /mnt/AlarmQueue.xml
rm -rf /mnt/spotify.preset
rm -rf /mnt/spotify.user

sleep 4
reboot
