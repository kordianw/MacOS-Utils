#!/bin/bash
#
# Script to backup Mac apps
# - either selected apps or any app in /Applications
#
# * By Kordian Witek <code [at] kordy.com>, Nov 2014
# $Id$
#
# * Change Log:
# $Log$

# what apps to backup?
SEL_APPS=(
  "AppCleaner"
  "Caffeine"
  "CCleaner"
  "Cocktail"
  "Degrees"
  "Etrecheck"
  "Evernote"
  "Flux"
  "Jump Desktop"
  "MPlayerX"
  "Memory Clean"
  "Microsoft Remote Desktop"
  "OnyX"
  "Skype"
  "TinkerTool"
  "WiFi Explorer"
  "uTorrent"
)

# destination
BKUP_DIR=~/Backups

# other config
APPS_DIR=/Applications
APPS_EXT=".app"



####################
PROG=`basename $0`
if [ $# -eq 0 -o "$1" = "-h" ]; then
  cat <<! >&2
$PROG: Script to backup Mac apps

Usage: $PROG [params] <filter>

       <filter>  filter the name of the app for backup
       -all      backup all selected apps (defined in config)
       -n        test mode, do not backup, just preview

       -h        this screen
!
else
  # check to ensure we're on the right platform
  [ -r "$APPS_DIR" ] || { echo "$PROG: Can't get read access to Mac apps dir \"$APPS_DIR\" ..." >&2; exit 1; }

  # check access to destination
  mkdir "$BKUP_DIR" 2>/dev/null
  [ -w "$BKUP_DIR" ] || { echo "$PROG: Can't get write access to bkup dir \"$BKUP_DIR\" ..." >&2; exit 1; }

  # deal with dry mode
  if [ "$1" == "-n" ]; then
    TEST_MODE="yes"
    shift
  fi

  # set up filter
  if [ "$1" == "-all" ]; then
    FILTER="."
  else
    FILTER="$1"

    # generate a bash array with all apps
    SEL_APPS=()
    for a in $APPS_DIR/*; do
      APP=`echo $a | sed 's/.*\///; s/\.app$//'`
      SEL_APPS=("${SEL_APPS[@]}" "$APP")
    done
  fi

  # Main Loop
  echo "$PROG: Backing up apps in \"$APPS_DIR\" ..."
  for app_name in "${SEL_APPS[@]}"; do
    # acknowledge filter
    if echo "$app_name" | grep -iq "$FILTER"; then
      APP="$APPS_DIR/$app_name$APPS_EXT"
      [ -d "$APP" ] || { echo "$PROG: Can't read app \"$app_name\" as \"$APP\" ..." >&2; exit 1; }

      # get the version of the app
      VERSION=`grep -A 1 CFBundleShortVersionString "$APP/Contents/Info.plist" |tail -1 | sed 's/.*<string>//; s/<.string>//'`
      [ -n "$VERSION" ] || VERSION=`grep -A 1 CFBundleVersion "$APP/Contents/Info.plist" |tail -1 | sed 's/.*<string>//; s/<.string>//'`
      [ -n "$VERSION" ] || { echo "$PROG: Can't work out version of \"$app_name\" in \"$APP\" ..." >&2; exit 1; }

      ZIP="$app_name v$VERSION.zip"

      # backup unless already exists
      if [ -r "$BKUP_DIR/$ZIP" ]; then
        SIZE=`ls -olh "$BKUP_DIR/$ZIP" | awk '{print $4}'`
        echo " -> skipping \"$app_name v$VERSION\" [$SIZE]: already backed up..."
      else
        echo "<*> backing up << $app_name v$VERSION >> ..."

        #
        # ACTUAL BACKUP
        #
        if [ -n "$TEST_MODE" ]; then
          # PREVIEW
          echo "WILL EXEC: zip -9rv \"$BKUP_DIR/$ZIP\" \"$APP\""
        else
          # EXECUTE
          cd "$APPS_DIR" && zip -9rv "$BKUP_DIR/$ZIP" "`basename \"$APP\"`"

          SIZE=`ls -olh "$BKUP_DIR/$ZIP" | awk '{print $4}'`
          echo " -> done: \"$app_name v$VERSION\" [$SIZE] in $BKUP_DIR ..."
        fi
      fi
    fi
  done
fi

# EOF
