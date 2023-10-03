#!/usr/bin/bash

sinks=$(pactl list sinks short | grep RUNNING | awk '{ print $1 }')
if [ -z "$sinks" ]; then
        sinks=$(pactl get-default-sink)
fi

echo "$sinks"

for SINK in $sinks
do
  pactl set-sink-mute "${SINK}" toggle
done
