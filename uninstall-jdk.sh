
echo sudo rm -rf /Library/Java/JavaVirtualMachines/jdk<version>.jdk
echo sudo rm -rf /Library/PreferencePanes/JavaControlPanel.prefPane
echo sudo rm -rf /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin


#
#            :launchctl => [
#                           'com.oracle.java.Helper-Tool',
#                           'com.oracle.java.Java-Updater',
#                          ],
#            :quit => [
#                      'com.oracle.java.Java-Updater',
#                      'net.java.openjdk.cmd',         # Java Control Panel
#                     ],
#            :files => [
#                       '/Library/Internet Plug-Ins/JavaAppletPlugin.plugin',
#                       "/Library/Java/JavaVirtualMachines/jdk#{version}.jdk/Contents",
#                       '/Library/PreferencePanes/JavaControlPanel.prefPane',
#                       '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK',
#                       '/Library/Java/Home',
#                       '/usr/lib/java/libjdns_sd.jnilib',
#
#                      ]
