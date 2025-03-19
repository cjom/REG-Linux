#!/bin/sh
mount -o remount,rw /boot
if [ ! -f  /boot/extlinux/extlinux.conf ]; then
    cp /boot/extlinux/reglinux.extlinux.conf /boot/extlinux/extlinux.conf
fi
/usr/bin/system-settings-set -f /boot/system-boot.conf system.es.atstartup 0
mount -o remount,ro /boot
touch /tmp/restart.please
emulationstation-standalone --stop-rebooting
killall emulationstation retroarch 2>/dev/null
shutdown -r now