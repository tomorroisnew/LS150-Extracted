#!/bin/sh
rm -rf /tmp/vendor_bak
mkdir -p /tmp/vendor_bak
### copy all files which required to backup to ram before upgrading ###
cp /vendor/wiimu /tmp/vendor_bak -ar

