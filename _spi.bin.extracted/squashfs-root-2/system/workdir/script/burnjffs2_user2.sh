#!/bin/sh

JFFS2FILE=/tmp/jffs2_user2.img
MTDPART=user2
FILESIZE=`cat $JFFS2FILE | wc -c`

cd /system/workdir
.  ./evn.sh
/system/workdir/script/backupJffs2_user2.sh

umount /vendor

mtd_write erase $MTDPART

mtd_write -o 0 -l $FILESIZE  write $JFFS2FILE $MTDPART 2>/tmp/burnprog.log

mount -t jffs2 /dev/mtdblock9 /vendor

/system/workdir/script/restoreJffs2_user2.sh
