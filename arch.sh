#!/usr/bin/env bash

set -eu
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

trap cleanup EXIT
cleanup () {
    rm -rf "$SCRIPT_DIR/pikaur"
}

sudo pacman -Sy --needed \
    audacity \
    autoconf \
    automake \
    chromium \
    cmake \
    dmenu \
    ethtool \
    gdb \
    gimp \
    git \
    gparted \
    i3-gaps \
    i3status-rust \
    i3lock \
    keepassxc \
    llvm \
    lshw \
    make \
    meld \
    ninja \
    perf \
    playerctl \
    pv \
    sshfs \
    tcpdump \
    thunderbird \
    tmux \
    tree \
    vim \
    vlc \
    wget \
    wireshark-cli \
    wireshark-qt \
    wmctrl \
    xterm \
    xorg-server \
    xorg-xinit \
    xorg-xrandr \
    zsh


if ! pacman -Qqe | grep pikaur > /dev/null; then
    sudo pacman -Sy --needed pyalpm
    git clone https://aur.archlinux.org/pikaur.git "$SCRIPT_DIR/pikaur" || true
    cd "$SCRIPT_DIR/pikaur"
    git pull
    makepkg -i
fi


pikaur -S --needed \
    spotify \
    visual-studio-code-bin \
