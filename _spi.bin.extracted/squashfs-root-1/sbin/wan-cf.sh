#!/bin/sh
var_ssid=`nvram_get 2860 ApCliSsid`
var_cmd="iwpriv apcli0 set ApCliSsid='${var_ssid}'"
var_auth=`nvram_get 2860 ApCliAuthMode`
var_encry=`nvram_get 2860 ApCliEncrypType`
var_pass=`nvram_get 2860 ApCliWPAPSK`
var_channel=`nvram_get 2860 ApCliChannel`
var_extch=`nvram_get 2860 ApCliExtCha`
var_wepkeyindex=`nvram_get 2860 ApCliWepKeyIndex`
var_wepkey1=`nvram_get 2860 ApCliKey1`
var_wepkey2=`nvram_get 2860 ApCliKey2`
var_wepkey3=`nvram_get 2860 ApCliKey3`
var_wepkey4=`nvram_get 2860 ApCliKey4`
iwpriv apcli0 set ApCliEnable=0
iwpriv apcli0 set ApCliAuthMode=$var_auth
iwpriv apcli0 set ApCliEncrypType=$var_encry
sh -c "${var_cmd}"
if [ "$var_encry" = "WEP" ]; then
	if [ "$var_wepkeyindex" = "1" ]; then
		iwpriv apcli0 set ApCliKey1=$var_wepkey1
	fi
	if [ "$var_wepkeyindex" = "2" ]; then
		iwpriv apcli0 set ApCliKey2=$var_wepkey2
	fi
	if [ "$var_wepkeyindex" = "3" ]; then
		iwpriv apcli0 set ApCliKey3=$var_wepkey3
	fi
	if [ "$var_wepkeyindex" = "4" ]; then
		iwpriv apcli0 set ApCliKey4=$var_wepkey4
	fi
else
	iwpriv apcli0 set ApCliWPAPSK=$var_pass
fi
iwpriv apcli0 set ApCliEnable=1