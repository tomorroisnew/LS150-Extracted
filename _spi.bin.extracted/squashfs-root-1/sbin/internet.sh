#!/bin/sh
#
# $Id: internet.sh,v 1.124.2.1 2011-07-07 03:43:38 michael Exp $
#
# usage: internet.sh
#

. /sbin/config.sh
. /sbin/global.sh

#lan_ip=`nvram_get 2860 lan_ipaddr`
#stp_en=`nvram_get 2860 stpEnabled`
#nat_en=`nvram_get 2860 natEnabled`
#radio_off=`nvram_get 2860 RadioOff`
#wifi_off=`nvram_get 2860 WiFiOff`
ra_Bssidnum=`nvram_get 2860 BssidNum`
rai_Bssidnum=`nvram_get rtdev BssidNum`

set_vlan_map()
{
	# vlan priority tag => skb->priority mapping
	vconfig set_ingress_map $1 0 0
	vconfig set_ingress_map $1 1 1
	vconfig set_ingress_map $1 2 2
	vconfig set_ingress_map $1 3 3
	vconfig set_ingress_map $1 4 4
	vconfig set_ingress_map $1 5 5
	vconfig set_ingress_map $1 6 6
	vconfig set_ingress_map $1 7 7

	# skb->priority => vlan priority tag mapping
	vconfig set_egress_map $1 0 0
	vconfig set_egress_map $1 1 1
	vconfig set_egress_map $1 2 2
	vconfig set_egress_map $1 3 3
	vconfig set_egress_map $1 4 4
	vconfig set_egress_map $1 5 5
	vconfig set_egress_map $1 6 6
	vconfig set_egress_map $1 7 7
}

ifRaxWdsxDown()
{
	num=16
	while [ "$num" -gt 0 ]
	do
		num=`expr $num - 1`
		ifconfig ra$num down 1>/dev/null 2>&1
	done

	ifconfig wds0 down 1>/dev/null 2>&1
	ifconfig wds1 down 1>/dev/null 2>&1
	ifconfig wds2 down 1>/dev/null 2>&1
	ifconfig wds3 down 1>/dev/null 2>&1

	ifconfig apcli0 down 1>/dev/null 2>&1

	ifconfig mesh0 down 1>/dev/null 2>&1
	echo -e "\n##### disable 1st wireless interface #####"
}

ifRaixWdsxDown()
{
	num=16
	while [ "$num" -gt 0 ]
	do
		num=`expr $num - 1`
		ifconfig rai$num down 1>/dev/null 2>&1
	done

	ifconfig wdsi0 down 1>/dev/null 2>&1
	ifconfig wdsi1 down 1>/dev/null 2>&1
	ifconfig wdsi2 down 1>/dev/null 2>&1
	ifconfig wdsi3 down 1>/dev/null 2>&1
	ifconfig apclii0 down 1>/dev/null 2>&1
	ifconfig meshi0 down 1>/dev/null 2>&1
	echo -e "\n##### disable 2nd wireless interface #####"
}

addBr0()
{
	brctl addbr br0

	# configure stp forward delay
	if [ "$wan_if" = "br0" -o "$lan_if" = "br0" ]; then
		stp=`nvram_get 2860 stpEnabled`
		if [ "$stp" = "1" ]; then
			brctl setfd br0 15
			brctl stp br0 1
		else
			brctl setfd br0 1
			brctl stp br0 0
		fi
		enableIPv6dad br0 2
	fi

}

addRax2Br0()
{
	num=1 
	brctl addif br0 ra0
        while [ $num -lt $ra_Bssidnum ] 
        do 
                ifconfig ra$num 0.0.0.0 1>/dev/null 2>&1
                brctl addif br0 ra$num 
                num=`expr $num + 1` 
        done 
}

addWds2Br0()
{
	wds_en=`nvram_get 2860 WdsEnable`
	if [ "$wds_en" != "0" ]; then
		ifconfig wds0 up 1>/dev/null 2>&1
		ifconfig wds1 up 1>/dev/null 2>&1
		ifconfig wds2 up 1>/dev/null 2>&1
		ifconfig wds3 up 1>/dev/null 2>&1
		brctl addif br0 wds0
		brctl addif br0 wds1
		brctl addif br0 wds2
		brctl addif br0 wds3
	fi
}

addMesh2Br0()
{
	meshenabled=`nvram_get 2860 MeshEnabled`
	if [ "$meshenabled" = "1" ]; then
		ifconfig mesh0 up 1>/dev/null 2>&1
		brctl addif br0 mesh0
		meshhostname=`nvram_get 2860 MeshHostName`
		iwpriv mesh0 set  MeshHostName="$meshhostname"
	fi
}

addRaix2Br0()
{
	if [ "$CONFIG_RT2880_INIC" == "" -a "$CONFIG_RTDEV" == "" ]; then
		return
	fi
	brctl addif br0 rai0
	num=1
	while [ "$num" -lt "$rai_Bssidnum" ]
	do
		ifconfig rai$num up 1>/dev/null 2>&1
		brctl addif br0 rai$num
		num=`expr $num + 1`
	done
	echo -e "\n##### enable 2nd wireless interface #####"
}

addInicWds2Br0()
{
	if [ "$CONFIG_RT2880_INIC" == "" -a "$CONFIG_RTDEV" == "" ]; then
		return
	fi
	wds_en=`nvram_get rtdev WdsEnable`
	if [ "$wds_en" != "0" ]; then
		ifconfig wdsi0 up 1>/dev/null 2>&1
		ifconfig wdsi1 up 1>/dev/null 2>&1
		ifconfig wdsi2 up 1>/dev/null 2>&1
		ifconfig wdsi3 up 1>/dev/null 2>&1
		brctl addif br0 wdsi0
		brctl addif br0 wdsi1
		brctl addif br0 wdsi2
		brctl addif br0 wdsi3
	fi
}

addRaL02Br0()
{
	if [ "$CONFIG_RT2561_AP" != "" ]; then
		brctl addif br0 raL0
	fi
}

#
#	ipv6 config#
#	$1:	interface name
#	$2:	dad_transmit number
#
enableIPv6dad()
{
	if [ "$CONFIG_IPV6" == "y" -o "$CONFIG_IPV6" == "m" ]; then
		echo "2" > /proc/sys/net/ipv6/conf/$1/accept_dad
		echo $2 > /proc/sys/net/ipv6/conf/$1/dad_transmits
	fi
}

disableIPv6dad()
{
	if [ "$CONFIG_IPV6" == "y" -o "$CONFIG_IPV6" == "m" ]; then
		echo "0" > /proc/sys/net/ipv6/conf/$1/accept_dad
	fi
}

genSysFiles()
{
	login=`nvram_get 2860 Login`
	pass=`nvram_get 2860 Password`
	if [ "$login" != "" -a "$pass" != "" ]; then
	echo "$login::0:0:Adminstrator:/:/bin/sh" > /etc/passwd
	echo "$login:x:0:$login" > /etc/group
		chpasswd.sh $login $pass
	fi
	if [ "$CONFIG_PPPOL2TP" == "y" ]; then
	echo "l2tp 1701/tcp l2f" > /etc/services
	echo "l2tp 1701/udp l2f" >> /etc/services
	fi
}

genDevNode()
{
        echo "# <device regex> <uid>:<gid> <octal permissions> [<@|$|*> <command>]" > /etc/mdev.conf
        #echo "# The special characters have the meaning:" >> /etc/mdev.conf
        #echo "# @ Run after creating the device." >> /etc/mdev.conf
        #echo "# $ Run before removing the device." >> /etc/mdev.conf
        #echo "# * Run both after creating and before removing the device." >> /etc/mdev.conf
        echo "sd[a-z][1-9] 0:0 0660 */sbin/automount.sh \$MDEV \$ACTION" >> /etc/mdev.conf
        echo "sd[a-z] 0:0 0660 */sbin/automount.sh \$MDEV \$ACTION" >> /etc/mdev.conf
        echo "mmcblk[0-9]p[0-9] 0:0 0660 */sbin/automount.sh \$MDEV \$ACTION" >> /etc/mdev.conf
        echo "mmcblk[0-9] 0:0 0660 */sbin/automount.sh \$MDEV \$ACTION" >> /etc/mdev.conf
        #if [ "$CONFIG_USB_SERIAL" = "y" ] || [ "$CONFIG_USB_SERIAL" = "m" ]; then
        #       echo "ttyUSB0 0:0 0660 @/sbin/autoconn3G.sh connect" >> /etc/mdev.conf
        #fi
        #if [ "$CONFIG_BLK_DEV_SR" = "y" ] || [ "$CONFIG_BLK_DEV_SR" = "m" ]; then
        #       echo "sr0 0:0 0660 @/sbin/autoconn3G.sh connect" >> /etc/mdev.conf
        #fi
        #if [ "$CONFIG_USB_SERIAL_HSO" = "y" ] || [ "$CONFIG_USB_SERIAL_HSO" = "m" ]; then
        #       echo "ttyHS0 0:0 0660 @/sbin/autoconn3G.sh connect" >> /etc/mdev.conf
        #fi

        #enable usb hot-plug feature
        echo "/sbin/mdev" > /proc/sys/kernel/hotplug

#Linux2.6 uses udev instead of devfs, we have to create static dev node by myself.
#if [ "$CONFIG_USB_EHCI_HCD" != "" -o "$CONFIG_DWC_OTG" != "" -a "$CONFIG_HOTPLUG" == "y" ]; then
	mounted=`mount | grep mdev | wc -l`
	#if [ $mounted -eq 0 ]; then
	mount -t ramfs mdev /dev
	mkdir /dev/pts
	mount -t devpts devpts /dev/pts
        mdev -s

        #mknod   /dev/video0      c       81      0
	mknod	/dev/ppp	 c	 108	 0   $cons
        mknod   /dev/spiS0       c       217     0
        mknod   /dev/i2cM0       c       218     0
        mknod   /dev/mt6605      c       219     0	
        mknod   /dev/flash0      c       200     0
        mknod   /dev/swnat0      c       210     0
        mknod   /dev/hwnat0      c       220     0
        mknod   /dev/acl0        c       230     0
        mknod   /dev/ac0         c       240     0
        mknod   /dev/mtr0        c       250     0
        mknod   /dev/nvram	 c       251     0
        mknod   /dev/gpio        c       252     0
        mknod   /dev/rdm0        c       253     0
        #mknod   /dev/pcm0        c       233     0
        mknod   /dev/i2s0        c       234     0	
        mknod   /dev/cls0        c       235     0
	mknod   /dev/spdif0      c       236     0
	mknod   /dev/vdsp        c       245     0
	mknod   /dev/slic        c       225     0
if [ "$CONFIG_SOUND" = "y" ] || [ "$CONFIG_SOUND" = "m" ]; then
	mknod   /dev/controlC0   c       116     0
	mknod   /dev/pcmC0D0c    c       116     24
	mknod   /dev/pcmC0D0p    c       116     16
fi
	
	#fi
}

echo "enter internet.sh"

genSysFiles
genDevNode
echo 1 > /proc/sys/net/ipv4/ip_forward
killall -9 watchdog 1>/dev/null 2>&1

# disable ipv6 DAD on all interfaces by default
if [ "$CONFIG_IPV6" == "y" -o "$CONFIG_IPV6" == "m" ]; then
	echo "0" > /proc/sys/net/ipv6/conf/default/accept_dad
fi

#rmmod ralink_wdt
#rmmod cls
#rmmod hw_nat
#rmmod raeth

# insmod all
#insmod -q bridge
#insmod -q mii
#insmod -q raeth
#ifconfig eth2 0.0.0.0

#ifRaxWdsxDown
#rmmod rt2860v2_ap_net
#rmmod rt2860v2_ap
#rmmod rt2860v2_ap_util

#rmmod rt2860v2_sta_net
#rmmod rt2860v2_sta
#rmmod rt2860v2_sta_util
ralink_init make_wireless_config rt2860

#ifconfig eth2.2 down
#wan_mac=`nvram_get 2860 WAN_MAC_ADDR`
#if [ "$wan_mac" != "FF:FF:FF:FF:FF:FF" ]; then
#ifconfig eth2.2 hw ether $wan_mac
#fi
#enableIPv6dad eth2.2 1

#ifconfig eth2.1 0.0.0.0
#ifconfig eth2.2 0.0.0.0
#ifconfig eth2.3 0.0.0.0
#ifconfig eth2.4 0.0.0.0
#ifconfig eth2.5 0.0.0.0

ifconfig lo 127.0.0.1
#ifconfig br0 down
#brctl delbr br0

# stop all
iptables --flush
iptables --flush -t nat
#iptables --flush -t mangle

echo "##### restore Ralink ESW to dump switch #####"
config-vlan.sh 2 0

#addBr0
#addRax2Br0
	lan.sh
	nat.sh

# in order to use broadcast IP address in L2 management daemon
route add -host 255.255.255.255 dev $lan_if

#close ethernet which MV donot use
#mii_mgr -s -p 0 -r 0 -v 0x3900
mii_mgr -s -p 1 -r 0 -v 0x3900
mii_mgr -s -p 2 -r 0 -v 0x3900
mii_mgr -s -p 3 -r 0 -v 0x3900
mii_mgr -s -p 4 -r 0 -v 0x3900

if [ -f /tmp/factory_restore_flag ]; then
	echo "factory_restore_flag found, need to run mdev -s to fix usb mount issue"
	mdev -s 
fi
cd /system/workdir
./live.sh
