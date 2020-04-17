#!/bin/sh
# remove GoogleSoftwareUpdate which comes with Chrome
#
# * By Kordian Witek <code [at] kordy.com>, Jan 2014
#

# first check nothing belonging to Google is running
if [ `ps auxw|egrep -ci 'chrome|keystone'` -gt 1 ]; then
  echo "Google processes running, please quit before rerunning:"
  ps auxw | egrep -i 'google|chrome|keystone'
  exit 1
fi

# uninstall
echo "* Uninstalling Google Software Update (Keystone Agent) Service:"
~/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/GoogleSoftwareUpdateAgent.app/Contents/Resources/install.py --uninstall
sudo /Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/GoogleSoftwareUpdateAgent.app/Contents/Resources/install.py --uninstall

# remove GoogleSoftwareUpdate
echo "* Removing Google Software Update (Keystone Agent) Service:"
set -x
rm -vf ~/Library/LaunchAgents/com.google.keystone.agent.plist
rm -vf ~/Library/Preferences/com.google.Keystone.Agent.plist
rm -vrf ~/Library/Caches/com.google.Keystone.Agent
rm -vrf ~/Library/Caches/com.google.Keystone
rm -vrf ~/Library/Google/GoogleSoftwareUpdate
rm -vf ~/Library/Logs/GoogleSoftwareUpdateAgent.log 
set +x

# ensure it can never be installed again
echo "* putting in a blocker file"
touch ~/Library/Google/GoogleSoftwareUpdate

echo "done."

# EOF
