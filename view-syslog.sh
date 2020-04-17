#!/bin/sh
# view syslog with filtering
# - include wake reasons
#
# * By Kordian Witek <code [at] kordy.com>, Nov 2014
#

# exclude:
GENERAL_FILTERS="<Debug>|<Notice>|last message repeated.*time"
SPECIFIC_FILTERS="en0.*Network is down|Already associated.*Bailing on|<Warning>: $"

# include:
INCLUDE_FILTERS="Wake reason|PMStats: Hibernate read took|en0: BSSID changed"

# repeated messages filter
REPEATED_FILTER="<Debug>|last message repeated|Already associated to|setting hostname to|network changed: v4.en0"

#########
if [ "$1" = "-repeat" ]; then
  syslog| egrep -v "$REPEATED_FILTER"| sed 's/^[A-z]* [0-9]* [0-9:]* //'|sort |uniq -c|sort -n |grep -v "^ *[12] "|tail -30
else
  TMP=/tmp/syslog-$$
  HOSTNAME=`hostname`

  # exclude
  syslog | egrep -v "$GENERAL_FILTERS|$SPECIFIC_FILTERS" > $TMP

  # include
  syslog | egrep "$INCLUDE_FILTERS" >> $TMP

  # view
  sort $TMP | sed "s/$HOSTNAME//" && rm -f $TMP
fi

# EOF
