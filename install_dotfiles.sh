#!/usr/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "${SCRIPT_DIR}/common.sh"

function run_as_user() {
    echo "Run with user $1:" "${@:2}"
    sudo -u "${@}"
}

function user_of_file() {
    local path;
    path="$(realpath -s -m "$1")"
    while [ ! -e "${path}" ]; do
        path="$(dirname "${path}")"
    done
    stat -c '%U' "${path}"
}

function fatal() {
    echo "${@}"
    exit 1
}

function backup_file() {

    local i=0
    local dest
    local file="$1"
    if [[ -e "${file}" ]]; then
        while true; do
            dest="${file}.old.${i}"
            if [[ ! -e "${dest}" ]]; then
                break;
            fi
            i=$(("${i}" + 1))
        done
        echo "Backing up '${file}' to '${dest}'"
        run_as_user "$(user_of_file "${file}")" mv "${file}" "${dest}"
    fi
}

function install() {
    local root=""
    local dst=""
    local user=""
    local OPTIND
    while getopts "u:d:p:r" o; do
        case "${o}" in
            u)
                user="${OPTARG}"
                ;;
            d)
                root="${OPTARG}"
                ;;
            p)
                dst="${OPTARG}"
                ;;
            r)
                root="/"
                ;;
            *)
                echo "Unknown arg '${o}'"
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    local src="$1"

    if [[ -n "${dst}" ]] && [[ -n "${root}" ]]; then
        fatal "Only one of -r or -p can be used at a time"
    fi

    if [[ -z "${dst}" ]] && [[ -z "${root}" ]]; then
        root="${HOME}"
    fi

    if [[ -n "${root}" ]]; then
        dst="${root}/${src}"
    fi

    dst=$(realpath -ms "${dst}")
    src=$(realpath -ms "$SCRIPT_DIR/${src}")

    if [[ -z "${user}" ]]; then
        user="$(user_of_file "${dst}")"
    fi

    echo "${user}: ${src} => ${dst}"

    if [ ! -f "${src}" ] && [ ! -d "${src}" ]; then
        echo "${src} is not a file";
        return 1;
    fi

    if [ -e "${dst}" ] || [ -L "${dst}" ]; then
        if [ "${src}" -ef "$(readlink "${dst}")" ]; then
            return
        fi
    fi

    if [ -e "${dst}" ]; then
        run_as_user "${user}" "${merge_cmd[@]}" "${src}" "${dst}"
    fi
    backup_file "${dst}"
    echo "${dst} will now be linked."

    run_as_user "${user}" mkdir -p "$(dirname "${dst}")"
    run_as_user "${user}" ln -s "${src}" "${dst}"
}


if [ ! -e "${HOME}/.dotfiles" ]; then
    ln -s "$(realpath "$SCRIPT_DIR")/" "${HOME}/.dotfiles"

fi
SCRIPT_DIR="${HOME}/.dotfiles"

if [ "${CORE}" -eq 1 ]; then
    install .oh-my-zsh/themes/oke.zsh-theme
    install .zshrc
    install .vimrc
    install .winfo.sh
fi

if [ "${WORKSTATION}" -eq 1 ]; then
    install .Xmodmap
    install .Xresources
    install .xinitrc
    install .config/i3/config
    install .config/i3status-rust/config.toml
fi

if [ "${SYSTEM}" -eq 1 ] && [ "${WORKSTATION}" -eq 1 ]; then
    install -r etc/modprobe.d/nobeep.conf
    install -r etc/systemd/logind.conf
    install -r etc/acpi/handler.sh
    install -r etc/acpi/toggle_mute.sh
    install -r etc/acpi/volume.sh
    install -r usr/share/X11/xorg.conf.d/40-libinput.confxml
    install -r etc/udev/rules.d/backlight.rules
fi

if [ "${EXTRA}" -eq 1 ] && [ "${WORKSTATION}" -eq 1 ]; then
    install .config/darktable/darktablerc
    install -r usr/share/darktable/noiseprofiles.json
    install -r usr/share/lensfun/version_1/compact-sony.
fi

if [ "${DEV}" -eq 1 ] && [ "${WORKSTATION}" -eq 1 ]; then
    install .config/Code/User/settings.json
    install .config/Code/User/keybindings.json
fi
