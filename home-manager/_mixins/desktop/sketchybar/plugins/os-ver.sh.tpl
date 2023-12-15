#!/usr/bin/env sh

TOPPROC=$(sw_vers -productVersion; echo " ("; uname -r; echo ")")

{{bin.sketchybar}} --set $NAME icon="" label="$TOPPROC"
