#!/bin/sh
#
# $Id: lan.sh,v 1.27 2010-12-03 09:50:18 winfred Exp $
#
# usage: wan.sh
#

. /sbin/global.sh

# stop all
killall -q udhcpd
#killall -q lld2d
killall -q igmpproxy
killall -q upnpd
#killall -q radvd
#killall -q pppoe-relay
killall -q dnsmasq
rm -rf /var/run/lld2d-*
echo "" > /var/udhcpd.leases

# ip address
ip=`nvram_get 2860 lan_ipaddr`
nm="255.255.255.0"
opmode="3"
ifconfig $lan_if $ip netmask $nm

ifconfig "ra0:9" down
ifconfig "eth2:9" down

# hostname
host=`nvram_get 2860 SSID1`
if [ "$host" = "" ]; then
	host="wiimu"
	nvram_set 2860 HostName wiimu
fi
hostname $host
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
echo "$ip $host.ralinktech.com $host" >> /etc/hosts

# dhcp server
#start=`nvram_get 2860 dhcpStart`
#end=`nvram_get 2860 dhcpEnd`
#mask=`nvram_get 2860 dhcpMask`
#pd=`nvram_get 2860 dhcpPriDns`
#sd=`nvram_get 2860 dhcpSecDns`
#gw=`nvram_get 2860 dhcpGateway`
#lease="86400"
#static1=""
#static2=""
#static3=""

#	config-udhcpd.sh -s $start
#	config-udhcpd.sh -e $end
#	config-udhcpd.sh -i $lan_if
#	config-udhcpd.sh -m $mask
#	if [ "$pd" != "" -o "$sd" != "" ]; then
#		config-udhcpd.sh -d $pd $sd
#	fi
#	if [ "$gw" != "" ]; then
#		config-udhcpd.sh -g $gw
#	fi
#	if [ "$lease" != "" ]; then
#		config-udhcpd.sh -t $lease
#	fi

#	config-udhcpd.sh -S

#if [ -f "/tmp/internet_sh_completed" ]; then
#config-udhcpd.sh -r 0.1
#else
#config-udhcpd.sh -U 0
#fi

# lltd
#lltd=`nvram_get 2860 lltdEnabled`
#if [ "$lltd" = "1" ]; then
#	lld2d $lan_if
#fi

# igmpproxy
#igmp=`nvram_get 2860 igmpEnabled`
#if [ "$igmp" = "1" ]; then
#	config-igmpproxy.sh $wan_if $lan_if
#fi

# upnp
#if [ "$opmode" = "0" -o "$opmode" = "1" ]; then
#	upnp=`nvram_get 2860 upnpEnabled`
#	if [ "$upnp" = "1" ]; then
#		route add -net 239.0.0.0 netmask 255.0.0.0 dev $lan_if
#		upnp_xml.sh $ip
#		upnpd -f $wan_ppp_if $lan_if &
#	fi
#fi

# radvd
#radvd=`nvram_get 2860 radvdEnabled`
#ifconfig sit0 down
#echo "0" > /proc/sys/net/ipv6/conf/all/forwarding
#if [ "$radvd" = "1" ]; then
#	echo "1" > /proc/sys/net/ipv6/conf/all/forwarding
#	ifconfig sit0 up
#	ifconfig sit0 add 2002:1101:101::1101:101/16
#	route -A inet6 add 2000::/3 gw ::17.1.1.20 dev sit0
#	route -A inet6 add 2002:1101:101:0::/64 dev ra0
#	radvd -C /etc_ro/radvd.conf -d 1 &
#fi

# pppoe-relay
#pppr=`nvram_get 2860 pppoeREnabled`
#if [ "$pppr" = "1" ]; then
#	pppoe-relay -S $wan_if -B $lan_if
#fi

# dns proxy
#dnsp=`nvram_get 2860 dnsPEnabled`
#if [ "$dnsp" = "1" ]; then
#dnsmasq &
#fi

