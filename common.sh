#!/usr/bin/bash

ALL=0
CORE=0
DEV=0
EXTRA=0
WORKSTATION=0

if [[ "$#" -eq 0 ]]; then
    ALL=1
fi

options=$(getopt -o acdew -l all,core,dev,extra,workstation -- "$@")
[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    exit 1
}

eval set -- "$options"
while true; do
    case "$1" in
    -a | --all)
        ALL=1
        ;;
    -c | --core)
        CORE=1
        ;;
    -d | --dev)
        DEV=1
        ;;
    -e | --extra)
        EXTRA=1
        ;;
    -w | --workstation)
        WORKSTATION=1
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

if [ "${ALL}" -eq 1 ]; then
    WORKSTATION=1
    EXTRA=1
    DEV=1
fi
