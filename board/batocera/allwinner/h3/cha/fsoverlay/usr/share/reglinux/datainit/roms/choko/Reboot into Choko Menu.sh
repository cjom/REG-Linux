#!/bin/sh
mount -o remount,rw /boot
mv /boot/extlinux/extlinux.conf /boot/extlinux/reglinux.extlinux.conf
mount -o remount,ro /boot
touch /tmp/restart.please
emulationstation-standalone --stop-rebooting
killall emulationstation retroarch 2>/dev/null
shutdown -r now