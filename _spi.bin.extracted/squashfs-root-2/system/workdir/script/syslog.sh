#!/bin/sh

rm -f /tmp/web/sys.log
echo -e "=========================================== kernel log ================================================\n\n\n" > /tmp/web/sys.log
cat /proc/kmsg >> /tmp/web/sys.log &
KPID=$!
sleep 2
kill -9 $KPID
echo -e "=========================================== apllication log ===========================================\n\n\n" >> /tmp/web/sys.log
cat /proc/conlog >> /tmp/web/sys.log &
APID=$!
sleep 4
kill -9 $APID

