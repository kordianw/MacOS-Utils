#!/bin/sh
# Displays a list of all startup/login items
#
# * By Kordian Witek <code [at] kordy.com>, Jan 2014
#

LIBRARY_LOCATIONS="/Library/LaunchAgents /Library/LaunchDaemons /Library/StartupItems"
SYSTEM_LOCATIONS="/System/Library/LaunchAgents /System/Library/LaunchDaemons /System/Library/StartupItems"
USER_LOCATIONS="$HOME/Library/LaunchAgents"

EXEMPTIONS="^\.$|^\.\.$|^com\.apple|org.openbsd.ssh-agent.plist|^bootps.plist|^com.danga.memcached.plist|^com.vix.cron.plist|^exec.plist|^finger.plist|^ftp.plist|^login.plist|^ntalk.plist|^org.apache.httpd.plist|^org.cups.cups-lpd.plist|^org.cups.cupsd.plist|^org.net-snmp.snmpd.plist|^org.ntp.ntpd.plist|^org.openldap.slapd.plist|^org.postfix.master.plist|^shell.plist|^ssh.plist|^telnet.plist|^tftp.plist"

# List Startup Items
for a in $LIBRARY_LOCATIONS $SYSTEM_LOCATIONS $USER_LOCATIONS; do
  ls -d "$a" 2>/dev/null | sed 's/^/-> /; s/$/:/'
  ls -a "$a" | egrep -v "$EXEMPTIONS"
done

# Kernel Extensions
echo "-> Kernel Extensions:"
kextstat| egrep -v "^Index | com\.apple\."

# Other Startup Items
echo "-> Login Items:"
osascript -e 'tell application "System Events" to get every login item'

echo "-> Crontabs (for $USER):"
crontab -l 2>/dev/null

# EOF
