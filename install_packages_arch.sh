#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "${SCRIPT_DIR}/common.sh"

trap cleanup EXIT
cleanup () {
    rm -rf "$SCRIPT_DIR/pikaur"
}

declare -ar pkgs_system_base=(
    autoconf
    automake
    cmake
    ethtool
    gcc
    gdb
    git
    gitui
    htop
    lshw
    make
    pv
    sshfs
    tcpdump
    tmux
    tree
    vim
    wget
    zsh
)

declare -ar pkgs_system_workstation=(
    alsa-utils
    networkmanager
    pulseaudio
)

declare -ar pkgs_tools_dev=(
    llvm
    man-db
    man-pages
    perf
    ninja
)

declare -ar pkgs_tools_dev_extra=(
    cargo
    go
    nodejs
    npm
    rust
)

declare -ar pkgs_i3_environment=(
    acpilight
    dmenu
    i3-gaps
    i3status-rust
    i3lock-color
    network-manager-applet
    playerctl
    rofi
    ttf-font-awesome
    wmctrl
    xidlehook pkgconf # undocumented dependency
    xss-lock
    xterm
    xorg-server
    xorg-xinit
    xorg-xrandr
)

declare -ar pkgs_apps_core=(
    chromium
    firefox
    nextcloud-client
    pavucontrol
    protonmail-bridge-bin
    thunar gvfs gvfs-mtp thunar-archive-plugin thunar-media-tags-plugin tumbler ffmpegthumbnailer
    thunderbird
)

declare -ar pkgs_apps_dev=(
    meld
    tk # git gui
    visual-studio-code-bin
)

declare -ar pkgs_apps_extra=(
    audacity
    darktable
    gimp
    gnucash
    keepassxc
    spotify
    vlc
)

mapfile -t pkgl_all < <( compgen -v pkgs_ )

declare -a pkgl_not_used=("${pkgl_all[@]}")
declare -a packages_to_install=()
declare -a pkgl_used=()

function add_pkg_list() {
    local -r list_name="$1"
    local -n list_packages="$1"

    for i in "${!pkgl_not_used[@]}"; do
        if [[ ${pkgl_not_used[i]} = "${list_name}" ]]; then
            unset 'pkgl_not_used[i]'
        fi
    done

    pkgl_used+=("${list_name}")
    packages_to_install+=("${list_packages[@]}")
}

if [ "${CORE}" -eq 1 ]; then
    add_pkg_list pkgs_system_base
fi


if [ "${WORKSTATION}" -eq 1 ]; then
    add_pkg_list pkgs_system_workstation
    add_pkg_list pkgs_i3_environment
    add_pkg_list pkgs_apps_core
fi

if [ "${DEV}" -eq 1 ]; then
    add_pkg_list pkgs_tools_dev
fi
if [ "${DEV}" -eq 1 ] && [ "${EXTRA}" -eq 1 ]; then
    add_pkg_list pkgs_tools_dev_extra
fi
if [ "${DEV}" -eq 1 ] && [ "${WORKSTATION}" -eq 1 ]; then
    add_pkg_list pkgs_apps_dev
fi

if [ "${EXTRA}" -eq 1 ] && [ "${WORKSTATION}" -eq 1 ]; then
    add_pkg_list pkgs_apps_extra
fi

for arg in "${@:1}"; do
    add_pkg_list "${arg}"
done


printf "Packets to install:\n"
printf "\t%s\n" "${packages_to_install[@]}"

printf "\nNot installed groups:\n"
printf "\t%s\n" "${pkgl_not_used[@]}"

printf "\nInstalled groups:\n"
printf "\t%s\n" "${pkgl_used[@]}"

if ! pacman -Qqe | grep pikaur > /dev/null; then
    sudo pacman -Suy make fakeroot which
    git clone https://aur.archlinux.org/pikaur.git "$SCRIPT_DIR/pikaur" || true
    cd "$SCRIPT_DIR/pikaur"
    git pull
    makepkg -irs
fi

sudo pikaur -Sy --noedit --needed "${packages_to_install[@]}"

if [ "${CORE}" -eq 1 ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
fi
