#!/bin/sh
#
# $Id: wan.sh,v 1.21 2010-03-10 13:48:06 chhung Exp $
#
# usage: wan.sh
#

. /sbin/global.sh

echo 1 > /proc/sys/vm/panic_on_oom

# stop all
killall -q syslogd
killall -q udhcpc
#killall -q pppd
#killall -q l2tpd
#killall -q openl2tpd

#udhcpc -i eth2 -s /sbin/udhcpc.sh -p /var/run/udhcpc.pid &
#udhcpc -i apcli0 -s /sbin/udhcpc_wl.sh -p /var/run/udhcpc.pid &
iwpriv apcli0 set ApCliEnable=0
var_channel=`nvram_get 2860 Channel`
iwpriv ra0 set Channel=$var_channel
