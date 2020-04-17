#!/bin/sh
# set display/system sleep & hibernate settings
# - assumes that: `pmset -g disk` lists battery settings before AC settings
#
# * By Kordian Witek <code [at] kordy.com>, Jan 2014
#

# after how many minutes switch off display?
BATTERY_DISPLAY_SLEEP=2
CHARGER_DISPLAY_SLEEP=5

# after how many minutes for system to go to sleep?
# - default is 1 min, which means when display goes blank
BATTERY_SYSTEM_SLEEP=15
CHARGER_SYSTEM_SLEEP=60

# afer how many hours do want to hibernate?
BATTERY_SYSTEM_HIBERNATE=3
CHARGER_SYSTEM_HIBERNATE=18


##########################

# display current values
TMP=/tmp/pmset-$$.tmp
pmset -g > $TMP
echo "* current Power Settings:"
echo "  - current profile: << `awk '/\*$/{print $1}' $TMP` >>"
echo "  - turn off display after: `awk '/displaysleep/{print $2}' $TMP` minutes"
echo "  - put disk to sleep after: `awk '/disksleep/{print $2}' $TMP` minutes"
echo "  - overall system sleep after: `awk '/ sleep/{print $2}' $TMP` minutes"
echo "  - system standby/hibernate after: `awk '/standbydelay/{print $2/60/60}' $TMP` hours"
echo "  - AC full auto-poweroff after: `awk '/autopoweroffdelay/{print $2/60/60}' $TMP` hours (AC only)"
echo "  Other Settings (for this profile):"
echo "  - automatic display half-dim on battery power: `awk '/halfdim/{print $2}' $TMP`"
echo "  - turn down display brightness switching to this power source: `pmset -g disk |awk '/lessbright/{print $2}'`"
echo "  - prevent sleep when TTYs are active (eg: SSH): `awk '/ttyskeepawake/{print $2}' $TMP`"
echo "  - wake the machine when lid is opened: `awk '/lidwake/{print $2}' $TMP`"
echo "  - wake the machine when power source (AC/battery) is changed: `awk '/acwake/{print $2}' $TMP`"
echo "  - wake the machine on Network activity: `awk '/womp/{print $2}' $TMP`"
echo "  - system will auto-wake to check mail (dark-wakes): `awk '/darkwakes/{print $2}' $TMP`"
echo "  - status of hibernate option: `awk '/hibernatemode/{print $2}' $TMP` (0:disabled, 3:enabled)"
echo "  - status of hibernate file: `ls -loh /var/vm/sleepimage | awk '{print $4,$5,$6,$7,$8}'`"
rm -f $TMP

# display power status
echo "* Battery status: `pmset -g batt | awk '!/Now drawing/{print $2,$3,$4,$5}'`"

# get current sleep & hibernate settings
pmset -g disk |egrep ":| sleep|displaysleep" > $TMP
SLEEP_BATT_MINS=`head -3 $TMP`
SLEEP_AC_MINS=`tail -3 $TMP`
pmset -g disk |awk '/standbydelay/{print $2/60/60}' > $TMP
HIB_BATT_HRS=`head -1 $TMP`
HIB_AC_HRS=`tail -1 $TMP`
rm -f $TMP

# display current reference for the values we will change
echo && echo "* Current DISPLAY/SLEEP/HIBERNATE settings to update:"
echo "$SLEEP_BATT_MINS"
echo " hibernate            $HIB_BATT_HRS hrs"
echo "$SLEEP_AC_MINS"
echo " hibernate            $HIB_AC_HRS hrs"

# confirm
echo & /bin/echo -n "Do you want to set custom settings $BATTERY_DISPLAY_SLEEP/${BATTERY_SYSTEM_SLEEP}mins/${BATTERY_SYSTEM_HIBERNATE}hrs & $CHARGER_DISPLAY_SLEEP/${CHARGER_SYSTEM_SLEEP}mins/${CHARGER_SYSTEM_HIBERNATE}hrs? [y/N] "
read CONFIRM
if [ "$CONFIRM" != "y" ]; then
  echo "...aborting." 2>&1
  exit 1
fi

# set system sleep settings (battery/charger)
echo && echo "-> setting <<battery>> overall SYSTEM SLEEP delay to $BATTERY_SYSTEM_SLEEP minutes..."
sudo pmset -b sleep $BATTERY_SYSTEM_SLEEP
echo "-> setting <<charger>> overall SYSTEM SLEEP delay to $CHARGER_SYSTEM_SLEEP minutes..."
sudo pmset -c sleep $CHARGER_SYSTEM_SLEEP

# set display sleep settings (battery/charger)
echo && echo "-> setting <<battery>> DISPLAY SLEEP delay to $BATTERY_DISPLAY_SLEEP minutes..."
sudo pmset -b displaysleep $BATTERY_DISPLAY_SLEEP
echo "-> setting <<charger>> DISPLAY SLEEP delay to $CHARGER_DISPLAY_SLEEP minutes..."
sudo pmset -c displaysleep $CHARGER_DISPLAY_SLEEP

# set hibernate settings
echo && echo "-> setting <<battery>> overall SYSTEM HIBERNATE delay to $BATTERY_SYSTEM_HIBERNATE hours..."
BATTERY_SYSTEM_HIBERNATE=$(($BATTERY_SYSTEM_HIBERNATE * 60 * 60))
BATTERY_POWEROFFDELAY=$((60 * 60 * 1 + $BATTERY_SYSTEM_HIBERNATE))
sudo pmset -b standbydelay $BATTERY_SYSTEM_HIBERNATE
sudo pmset -b autopoweroffdelay $BATTERY_POWEROFFDELAY
echo "-> setting <<charger>> overall SYSTEM HIBERNATE delay to $CHARGER_SYSTEM_HIBERNATE hours..."
CHARGER_SYSTEM_HIBERNATE=$(($CHARGER_SYSTEM_HIBERNATE * 60 * 60))
CHARGER_POWEROFFDELAY=$((60 * 60 * 1 + $CHARGER_SYSTEM_HIBERNATE))
sudo pmset -c standbydelay $CHARGER_SYSTEM_HIBERNATE
sudo pmset -c autopoweroffdelay $CHARGER_POWEROFFDELAY

# verify settings
echo && echo "* verifying settings:"
pmset -g disk |egrep ":| sleep|displaysleep"
echo "Hibernate Settings (battery/AC):"
pmset -g disk |awk '/standbydelay/{print " "$1,$2/60/60" hours"}'

# EOF
