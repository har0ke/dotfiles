#!/usr/bin/env bash

set -eu
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

trap cleanup EXIT
cleanup () {
    rm -rf "$SCRIPT_DIR/pikaur"
}

declare -ar base_system=(
    alsa-utils
    ethtool
    htop
    llvm
    lshw
    make
    man-db
    man-pages
    networkmanager
    perf
    pulseaudio
    pv
    sshfs
    tcpdump
    tmux
    tree
    vim
    wget
    zsh
)

declare -ar base_dev=(
    autoconf
    automake
    cmake
    gdb
    git
    ninja
)

declare -ar i3_environment=(
    acpilight
    dmenu
    i3-gaps
    i3status-rust
    i3lock-color
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
    network-manager-applet
)


declare -ar apps_core=(
    chromium
    firefox
    keepassxc
    nextcloud-client
    pavucontrol
    thunderbird
    protonmail-bridge-bin
)

declare -ar apps_dev=(
    meld
    tk # git gui
    visual-studio-code-bin
)

declare -ar apps_extra=(
    audacity
    darktable
    gimp
    spotify
    vlc
)


if ! pacman -Qqe | grep pikaur > /dev/null; then
    sudo pacman -Sy --needed git pyalm python-markdown-it-py asp \
        python-defusedxml python-pysocks
    git clone https://aur.archlinux.org/pikaur.git "$SCRIPT_DIR/pikaur" || true
    cd "$SCRIPT_DIR/pikaur"
    git pull
    makepkg -i
fi


sudo pikaur -Sy --needed \
    "${base_system[@]}" \
    "${base_dev[@]}" \
    "${i3_environment[@]}" \
    "${apps_core[@]}" \
    "${apps_dev[@]}" \
    "${apps_extra[@]}"
