#!/bin/bash
# Default acpi script that takes an entry for all actions

for_each_pa_user() {
     pgrep Xorg | \
	     xargs -i ps -o uid= -p {} | \
	     xargs -i sudo -u \#{} DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/{} $@
}

case "$1" in
    button/brightnessup)
	for_each_pa_user sudo xbacklight -inc 10
	;;
    button/brightnessdown)
	for_each_pa_user sudo xbacklight -dec 10
	;;
    button/volumedown)
	for_each_pa_user /etc/acpi/volume.sh -10%
	;;
    button/volumeup)
	for_each_pa_user /etc/acpi/volume.sh +10%
	;;
    button/mute)
	for_each_pa_user /etc/acpi/toggle_mute.sh
	;;
    cd/play)
	for_each_pa_user playerctl play-pause
	;;
    cd/next)
	for_each_pa_user playerctl next
	;;
    cd/prev)
	for_each_pa_user playerctl previous
	;;
    button/power)
        case "$2" in
            PBTN|PWRF)
                logger 'PowerButton pressed'
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    button/sleep)
        case "$2" in
            SLPB|SBTN)
                logger 'SleepButton pressed'
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            AC|ACAD|ADP0)
                case "$4" in
                    00000000)
                        logger 'AC unpluged'
                        ;;
                    00000001)
                        logger 'AC pluged'
                        ;;
                esac
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    battery)
        case "$2" in
            BAT0)
                case "$4" in
                    00000000)
                        logger 'Battery online'
                        ;;
                    00000001)
                        logger 'Battery offline'
                        ;;
                esac
                ;;
            CPU0)
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/lid)
        case "$3" in
            close)
                logger 'LID closed'
                ;;
            open)
                logger 'LID opened'
                ;;
            *)
                logger "ACPI action undefined: $3"
                ;;
    esac
    ;;
    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;
esac

# vim:set ts=4 sw=4 ft=sh et:
