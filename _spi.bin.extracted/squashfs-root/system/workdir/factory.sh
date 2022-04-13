#!/bin/sh

USBLOGFILENAME=factory.log
SDLOGFILENAME=factory.log
USBUPSCRIPTFILENAME=usbupfirmware.sh
USBUPSCRIPFACTORY=factory.sh
SDTESTFILE=/media/sdb/sd.log
SDTESTRESULT=1
USBTESTRESULT=1
GPIOTESTRESULT=1
USBUPRESULT=0
SDCARD=""

module="A11"
check_module()
{
cat /system/workdir/MVver | grep "WiiMu-A02"
if [ $? -eq 0 ]; then
	module="A02"
fi
cat /system/workdir/MVver | grep "WiiMu-A31"
if [ $? -eq 0 ]; then
	module="A31"
fi
cat /system/workdir/MVver | grep "WiiMu-A28"
if [ $? -eq 0 ]; then
	module="A31"
fi
}


pass()
{
echo  pass!!!
echo  "#######################################################################" >>${USBLOGFILE}
echo  "##                                                                   ##" >>${USBLOGFILE}
echo  "##                 ########     ###     ######   ######              ##" >>${USBLOGFILE}
echo  "##                 ##     ##   ## ##   ##    ## ##    ##             ##" >>${USBLOGFILE}
echo  "##                 ##     ##  ##   ##  ##       ##                   ##" >>${USBLOGFILE}
echo  "##                 ########  ##     ##  ######   ######              ##" >>${USBLOGFILE}
echo  "##                 ##        #########       ##       ##             ##" >>${USBLOGFILE}
echo  "##                 ##        ##     ## ##    ## ##    ##             ##" >>${USBLOGFILE}
echo  "##                 ##        ##     ##  ######   ######              ##" >>${USBLOGFILE} 
echo  "##                                                                   ##" >>${USBLOGFILE}
echo  "#######################################################################" >>${USBLOGFILE}
}

fail()
{
echo  fail!!!
echo  "#######################################################################" >>${USBLOGFILE}
echo  "##                                                                   ##" >>${USBLOGFILE}
echo  "##                 ########     ###       ##    ##                   ##" >>${USBLOGFILE}
echo  "##                 ##          ## ##            ##                   ##" >>${USBLOGFILE}
echo  "##                 ##         ##   ##    ####   ##                   ##" >>${USBLOGFILE}
echo  "##                 ########  ##     ##    ##    ##                   ##" >>${USBLOGFILE}
echo  "##                 ##        #########    ##    ##                   ##" >>${USBLOGFILE}
echo  "##                 ##        ##     ##    ##    ##                   ##" >>${USBLOGFILE}
echo  "##                 ##        ##     ##   ####   ########             ##" >>${USBLOGFILE} 
echo  "##                                                                   ##" >>${USBLOGFILE}
echo  "#######################################################################" >>${USBLOGFILE}
}

USBdetect()
{
UDISK=`cat /proc/mounts| grep "/media/sda" | sed -n 's|.*\(/media/.*[[:space:]]\).*|\1|p' | sed 's/^[ \t]\+//;s/[ \t].*//'`
echo UDISK is $UDISK
}

SDdetect()
{
SDCARD=`cat /proc/mounts| grep "/media/mmcblk" | sed -n 's|.*\(/media/.*[[:space:]]\).*|\1|p' | sed 's/^[ \t]\+//;s/[ \t].*//'`
echo SDCARD is $SDCARD
}


USBtest()
{
USBTESTRESULT=0

if test "$UDISK" == ""
then
	echo no UDisk!!!
	fail
	USBTESTRESULT=0
	return
fi

for i in $UDISK
do
	USBLOGFILE=$i/${USBLOGFILENAME}
done

if test -e ${USBLOGFILE}
then
	echo ${USBLOGFILE} exist, rm it!
	rm -rf ${USBLOGFILE}
	if test -e ${USBLOGFILE}
	then
		echo rm ${USBLOGFILE} failed!
	fi
fi

echo =======================================================================	>>${USBLOGFILE}
echo                     														>>${USBLOGFILE}
echo                     														>>${USBLOGFILE}
echo USB TEST START!!!															>>${USBLOGFILE}
echo USB TEST will save this message into factory.log 							>>${USBLOGFILE}
echo USB TEST END!!!															>>${USBLOGFILE}
echo                     														>>${USBLOGFILE}          
if test -e ${USBLOGFILE}
then
	pass                                                        					
	USBTESTRESULT=1
else
	fail
	USBTESTRESULT=0
fi		                                                        					
echo                     														>>${USBLOGFILE}          
echo                     														>>${USBLOGFILE}
echo =======================================================================	>>${USBLOGFILE}
}

SDtest()
{
if [ "$module" == "A31" ]; then
	SDTESTRESULT=0
else
	SDTESTRESULT=1
	return
fi

if test "$SDCARD" == ""
then
	echo no SDCARD!!!
	fail
	SDTESTRESULT=0
	return
fi

for i in $SDCARD
do
	SDLOGFILE=$i/${SDLOGFILENAME}
done

if test -e ${SDLOGFILE}
then
	echo ${SDLOGFILE} exist, rm it!
	rm -rf ${SDLOGFILE}
	if test -e ${SDLOGFILE}
	then
		echo rm ${SDLOGFILE} failed!
	fi
fi

echo =======================================================================	>>${SDLOGFILE}
echo                     														>>${SDLOGFILE}
echo                     														>>${SDLOGFILE}
echo SD TEST START!!!															>>${SDLOGFILE}
echo SD TEST will save this message into factory.log 							>>${SDLOGFILE}
echo SD TEST END!!!															>>${SDLOGFILE}
echo                     														>>${SDLOGFILE}          
if test -e ${SDLOGFILE}
then
	pass                                                        					
	SDTESTRESULT=1
else
	fail
	SDTESTRESULT=0
fi		                                                        					
echo                     														>>${SDLOGFILE}          
echo                     														>>${SDLOGFILE}
echo =======================================================================	>>${SDLOGFILE}
}


GPIOtest()
{
echo =======================================================================	>>${USBLOGFILE}
echo                     														>>${USBLOGFILE}
echo                     														>>${USBLOGFILE}
echo GPIO TEST START!!!															>>${USBLOGFILE}
GPIOTESTRESULT=`factory_gpio f1`
echo $GPIOTESTRESULT                                                            >>${USBLOGFILE}
echo GPIO TEST END!!!								     						>>${USBLOGFILE}
echo                     														>>${USBLOGFILE}          
GPIOTESTRESULT=`factory_gpio f1 | grep 'TestResult' | sed 's/TestResult:*/\1/g'` 
if test $GPIOTESTRESULT -eq 0
then
	fail
else
	pass
fi		                                                        					
echo                     														>>${USBLOGFILE}          
echo                     														>>${USBLOGFILE}
echo =======================================================================	>>${USBLOGFILE}
}

#setup environment
. ./evn.sh
check_module

#factory_gpio f6

#restore

echo "clear nvram ++"
#ralink_init clear 2860
nvram_set WebInit 0
echo "clear nvram --"
sync

#for WIFI test
ated &
pkill udhcpc
ifconfig eth2 192.168.1.10 up
if [ "$module" == "A31" ]; then
	/sbin/config-vlan.sh 2 0
fi

#a01controller &


sleep 3
SDdetect
USBdetect
for i in $UDISK $SDCARD
do
	if test -e $i/${USBUPSCRIPTFILENAME}
	then
		echo ${USBUPSCRIPTFILENAME} exist, USB update!!!
		cd $i
		pwd
		./${USBUPSCRIPTFILENAME}
		USBSCRIPT=$?
		echo return is $USBSCRIPT
		## sleep forever
		while [ 1 ]; do 
			sleep 10
		done
	else
		echo ${USBUPSCRIPTFILENAME} not found!
		USBUPRESUL=0
		if test -e $i/${USBUPSCRIPFACTORY}
		then
			echo ${USBUPSCRIPFACTORY} exist, USB factory do!!!
			cd $i
			pwd
			./${USBUPSCRIPFACTORY}
			USBSCRIPT=$?
			echo return is $USBSCRIPT
			## sleep forever
			while [ 1 ]; do 
				sleep 10
			done
		else
			echo ${USBUPSCRIPFACTORY} not found!
		fi
	fi
done


#have not do the USB update firmware, do the factory test
if [ "${USBUPRESULT}" == "0" ]
then

	echo start factory test!!!
	#for USB test
	USBtest

if [ $USBTESTRESULT -eq 0 ]; then
	echo "udisk not found, do not test io"
else
	#for SD test
	SDtest

	#for GPIO test
	GPIOtest
	
	sync
fi	
	#for display the result
	sleep 1
	if  [ "$GPIOTESTRESULT" = "1" -a "$SDTESTRESULT" = "1" -a "$USBTESTRESULT" = "1" ]
	then
if [ "$module" == "A02" ]; then
	        factory_audio &
fi
                factory_gpio ok
	else
if [ "$module" == "A02" ]; then
	        factory_audio err &
fi
                factory_gpio err &
	fi

	#for audio test
	#factory_audio &
fi


rm -rf /vendor/download
rm -rf /vendor/downloadorg
rm -rf /mnt/keymap.xml
rm -rf /mnt/totalqueue.xml
rm -rf /mnt/.queue.init
rm -rf /mnt/defualt_ssid_mcu
umount /dev/mtdblock8 -l
umount /dev/mtdblock9 -l
mtd_write erase user
# do not erase user2 partition, voice files will be here
# mtd_write erase user2
sync
echo "factory script end!"
