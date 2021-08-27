
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

link_with_bkp() {
    SRC=$1
    DEST=$2

    if [ -d $DEST ]; then
        DEST=$DEST/$(basename $SRC)
    fi

    if [ ! -f $SRC ]; then
        echo "$SRC is not a file";
        return -1;
    fi

    if [ -f $DEST ]; then
        if [ "$SRC" -ef "$(readlink $DEST)" ]; then
            echo "$DEST is correctly linked"
            return
        fi
        if [ -f $DEST.old ]; then
            echo "$DEST.old exists. Cannot create backup."
            return -1;
        fi
        mv $DEST $DEST.old
    else
        echo "$DEST does not exist."
    fi
    ln -s $SRC $DEST
}

files="\
    .config/i3/config \
    .config/i3status-rust/config.toml \
    .config/i3status-rust/togglemute.sh \
    .config/i3status-rust/volumectl.sh \
    .config/Code/User/settings.json \
    .config/Code/User/keybindings.json \
    .Xmodmap \
    .Xresources \
    .xinitrc \
    etc/modprobe.d/nobeep.conf:/"


for f in $files; do
    BASE="$HOME/"
    if [[ "$f" =~ ":" ]]; then 
        BASE=$(echo "$f" | cut -f2 -d:)
        f=$(echo "$f" | cut -f1 -d:)
    fi
    dir="$BASE$(dirname $f)"
    mkdir -p "$dir"
    link_with_bkp $SCRIPT_DIR/$f $BASE$f
done

