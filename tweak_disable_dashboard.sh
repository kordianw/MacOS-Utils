#!/bin/bash
#
# Script to disable/enable OSX Dashboard
#
# * By Kordian Witek <code [at] kordy.com>, Nov 2014
#

FUNCTION_DESC="disable/enable OSX Dashboard"

# arrays of cmds to execute
DISABLE_CMDS=("defaults write com.apple.dashboard mcx-disabled -bool YES" "killall Dock")
ENABLE_CMDS=("defaults write com.apple.dashboard mcx-disabled -bool NO" "killall Dock")


####################
PROG=`basename $0`
if [ $# -eq 0 -o "$1" = "-h" ]; then
  cat <<! >&2
$PROG: Script to $FUNCTION_DESC

Usage: $PROG <-enable|-disable>
        -n      dry mode; show what will be executed
        -h      this screen
!
else
  # dry mode?
  if [ "$1" = "-n" ]; then
    DRY_MODE=1
    shift
  fi

  # set commands
  if [ "$1" == "-disable" ]; then
    EXECUTE=("${DISABLE_CMDS[@]}")
  elif [ "$1" == "-enable" ]; then
    EXECUTE=("${ENABLE_CMDS[@]}")
  else
    echo "$PROG: invalid option, see \`$PROG -h'" 1>&2
    exit 1
  fi

  #
  # EXEC
  #
  for cmd in "${EXECUTE[@]}"; do
    echo "EXEC: $cmd"
    if [ -z "$DRY_MODE" ]; then
      $cmd
      echo "RC=$?"
    fi
  done
fi

# EOF
