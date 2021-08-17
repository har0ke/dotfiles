for SINK in `pactl list sinks short | grep RUNNING | awk '{ print $1 }'`
do
  pactl set-sink-volume $SINK $VOLUME $1
done
