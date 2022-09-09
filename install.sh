#!/usr/bin/env bash

set -eu
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

run_as_user() {
    echo "Run with user $1: ${@:2}"
    sudo -u "$@"
}
set -e
link_with_bkp() {
    SRC=$2
    DEST=$3
    USER=$1
    if [ -d "$DEST" ]; then
        DEST="$DEST/$(basename "$SRC")"
    fi

    if [ ! -f "$SRC" ]; then
        echo "$SRC is not a file";
        return 1;
    fi

    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
        if [ "$SRC" -ef "$(readlink "$DEST")" ]; then
            echo "$DEST is correctly linked"
            return
        fi
        if [ -f "$DEST.old" ]; then
            echo "$DEST.old exists. Cannot create backup."
            return 1;
        fi
	echo "$DEST will be moved to $DEST.old"
        run_as_user "$USER" mv "$DEST" "$DEST.old"
    fi
    echo "$DEST will now be linked."
    run_as_user "$USER" ln -s "$SRC" "$DEST"
}

terminal_only="\
    .oh-my-zsh/themes/oke.zsh-theme \
    .zshrc \
    .vimrc
    .winfo.sh"

workstation="\
    .config/i3/config \
    .config/i3status-rust/config.toml \
    .config/Code/User/settings.json \
    .config/Code/User/keybindings.json \
    .Xmodmap \
    .Xresources \
    .xinitrc \
    .mod_keys.sh \
    .clear_red.sh \
    etc/modprobe.d/nobeep.conf:/:root \
    etc/acpi/handler.sh:/:root \
    etc/acpi/toggle_mute.sh:/:root \
    etc/acpi/volume.sh:/:root \
    usr/share/X11/xorg.conf.d/40-libinput.conf:/:root"

mode="$1"

if [[ "$mode" =~ "all" ]]; then
   mode="workstation terminal"
fi

files=""

if [[ $mode =~ "terminal" ]]; then
   files="$files $terminal_only"
fi

if [[ $mode =~ "workstation" ]]; then
   files="$files $workstation"
fi

for f in $files; do
    BASE="$HOME/"
    USER=$(whoami)
    if [[ "$f" =~ ":" ]]; then
        BASE=$(echo "$f" | cut -f2 -d:)
        USER=$(echo "$f" | cut -f3 -d:)
        f=$(echo "$f" | cut -f1 -d:)
    fi
    dir="$BASE$(dirname $f)"
    if [ ! -d $dir ]; then
    	run_as_user $USER mkdir -p "$dir"
    fi
    link_with_bkp $USER $SCRIPT_DIR/$f $BASE$f
done

