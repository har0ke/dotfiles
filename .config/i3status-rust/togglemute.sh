for SINK in `pactl list sinks short | grep RUNNING | awk '{ print $1 }'`
do
  pactl set-sink-mute $SINK toggle
done
