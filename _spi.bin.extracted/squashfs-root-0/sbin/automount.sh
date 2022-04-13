#! /bin/sh
if [ "$1" == "" ]; then
echo "parameter is none" 
exit 1
fi

if [ "$2" == "" ];then
action=add
else
action=$2
fi
mounted=`mount | grep $1 | wc -l`

# mounted, assume we umount
if [ $mounted -ge 1 ] && [ "$action" == "remove" ] ; then
echo "R/media/$1"
export LD_LIBRARY_PATH=/system/workdir/lib
/system/workdir/bin/mdevnotify 0 "/media/$1" &
if ! umount  -l "/media/$1"; then
#rm -fr "/media/$1"
exit 1
fi

#if ! rm -r "/media/$1"; then
#exit 1
#fi
# not mounted, lets mount under /media
elif  [ "$action" == "add" ]; then
if ! mkdir -p "/media/$1"; then
exit 1
fi
mounted=`mount | grep $1 | wc -l`
num=20
while [ $mounted -lt 1 -a $num -gt 0 ]
do
	mount "/dev/$1" "/media/$1"		
	mounted=`mount | grep $1 | wc -l`
	num=`expr $num - 1`
done
mounted=`mount | grep $1 | wc -l`
while [ $mounted -lt 1 -a $num -lt 3 ]
do
	ntfs-3g "/dev/$1" "/media/$1" -o force
	mounted=`mount | grep $1 | wc -l`
	num=`expr $num + 1`
done

if [ $mounted -lt 1 ]; then
#rm -r "/media/$1"
exit 1
fi
echo "A/media/$1" 
export LD_LIBRARY_PATH=/system/workdir/lib
mknod /dev/null c 1 3
/system/workdir/bin/mdevnotify 1 "/media/$1" &
fi

exit 0

