#!/bin/bash
 
# +----------------------------------------------------------------------+
# |                                                                      |
# | Mount the root file system / with the option noatime                 |
# |                                                                      |
# | * requires a reboot                                                  |
# | verify that "noatime" is enabled after a reboot:                     |
# | $ mount |grep " / "                                                  |
# +----------------------------------------------------------------------+

echo "Root FS Before:"
mount |grep " / "

STARTUP_FILE=/Library/LaunchDaemons/com.custom.noatime.plist
 
cat << EOF | sudo tee $STARTUP_FILE > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
      <string>com.custom.noatime</string>
      <key>ProgramArguments</key>
      <array>
        <string>mount</string>
        <string>-vuwo</string>
        <string>noatime</string>
        <string>/</string>
      </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
EOF

# finalise the setup
echo "Making changes..."
sudo chmod 644 $STARTUP_FILE
sudo chown root:wheel $STARTUP_FILE
sudo launchctl load -w $STARTUP_FILE

# EOF
