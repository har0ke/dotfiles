

sinks=$(pactl list sinks short | grep RUNNING | awk '{ print $1 }')
if [ -z "$sinks" ]; then
	sinks=$(pactl get-default-sink)
fi

echo "$sinks"


for SINK in $sinks
do
  volume=$(echo $1 | sed "s/%//g")
  if [[ $volume =~ "+" ]] || [[ $volume =~ "-" ]]; then
    volume=$(($(pactl get-sink-volume $SINK | grep -o -E "[0-9]+%" | head -1 | sed "s/%//g") $volume))
    echo $volume
    if [[ "${volume}" =~ "-" ]]; then
      volume="0"
    fi
    if [ "${#volume}" -gt "2" ]; then
      volume="100"
    fi
  fi

  echo "$volume"
  pactl set-sink-volume $SINK $volume%

done
