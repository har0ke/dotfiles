
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

link_with_bkp $SCRIPT_DIR/vscode/keybindings.json ~/.config/Code/User
link_with_bkp $SCRIPT_DIR/vscode/settings.json ~/.config/Code/User
