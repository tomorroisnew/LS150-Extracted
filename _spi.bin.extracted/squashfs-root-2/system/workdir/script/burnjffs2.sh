#!/bin/sh

JFFS2FILE=/tmp/jffs2.img
MTDPART=user
FILESIZE=`cat $JFFS2FILE | wc -c`

cd /system/workdir
.  ./evn.sh
/system/workdir/script/backupJffs2.sh

umount /mnt

mtd_write erase $MTDPART

mtd_write -o 0 -l $FILESIZE  write $JFFS2FILE $MTDPART 2>/tmp/burnprog.log

mount -t jffs2 /dev/mtdblock8 /mnt

/system/workdir/script/restoreJffs2.sh
