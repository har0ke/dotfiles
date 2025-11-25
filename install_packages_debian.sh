#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "${SCRIPT_DIR}/common.sh"

# No AUR helper needed on Debian, so cleanup is a no-op for symmetry
trap cleanup EXIT
cleanup () {
    :
}

# ---------- Package groups (Debian names) ----------

declare -ar pkgs_system_base=(
    autoconf
    automake
    build-essential
    cmake
    ethtool
    gcc
    gdb
    git
    htop
    lshw
    make
    pkg-config
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
    network-manager
    network-manager-gnome
    pulseaudio
)

declare -ar pkgs_tools_dev=(
    man-db
    manpages
)

declare -ar pkgs_tools_dev_extra=(
    cargo
    golang
    llvm
    ninja-build
    nodejs
    npm
    linux-perf
    rustc
)

declare -ar pkgs_i3_environment=(
    dmenu
    i3-wm
    i3status
    i3lock
    network-manager-gnome
    playerctl
    rofi
    fonts-font-awesome
    wmctrl
    xss-lock
    xterm
    xserver-xorg
    xinit
    x11-xserver-utils
)

declare -ar pkgs_apps_core=(
    chromium
    firefox-esr
    pavucontrol
    thunar
    gvfs
    gvfs-backends
    thunar-archive-plugin
    thunar-media-tags-plugin
    tumbler
    ffmpegthumbnailer
)

declare -ar pkgs_apps_dev=(
    meld
    tk
    # Visual Studio Code requires the Microsoft repository; install manually.
    # code
)

declare -ar pkgs_apps_extra=(
    audacity
    darktable
    gimp
    gnucash
    keepassxc
    nextcloud-desktop
    thunderbird
    vlc
    # The following require external repositories or vendor .deb files:
    # protonmail-bridge
    # spotify-client
)

# ---------- Group-selection plumbing (unchanged logic) ----------

mapfile -t pkgl_all < <( compgen -v pkgs_ )

declare -a pkgl_not_used=("${pkgl_all[@]}")
declare -a packages_to_install=()
declare -a pkgl_used=()

add_pkg_list() {
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

# Allow passing extra group names as positional arguments
for arg in "${@:1}"; do
    add_pkg_list "${arg}"
done

printf "Packages to install:\n"
printf "\t%s\n" "${packages_to_install[@]}"

printf "\nNot installed groups:\n"
printf "\t%s\n" "${pkgl_not_used[@]}"

printf "\nInstalled groups:\n"
printf "\t%s\n" "${pkgl_used[@]}"

# ---------- Install phase (Debian / apt) ----------

if ((${#packages_to_install[@]} > 0)); then
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends "${packages_to_install[@]}"
else
    echo "No package groups selected, nothing to install."
fi

if [ "${CORE}" -eq 1 ]; then
    # Same as Arch script; generic
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
fi
