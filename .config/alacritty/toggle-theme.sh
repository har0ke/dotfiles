#!/bin/sh
# Toggle Alacritty between light and dark themes

THEME_DIR="$HOME/.config/alacritty/themes"
CURRENT="$THEME_DIR/current-theme.toml"

# Read current theme by checking the symlink target
if [ -L "$CURRENT" ]; then
    target=$(readlink "$CURRENT")
    case "$target" in
        *light*) ln -sf "$THEME_DIR/dark.toml" "$CURRENT" ;;
        *)       ln -sf "$THEME_DIR/light.toml" "$CURRENT" ;;
    esac
else
    # No symlink yet, default to dark
    ln -sf "$THEME_DIR/dark.toml" "$CURRENT"
fi
