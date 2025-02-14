@echo off

call %userprofile%\qkomorebi.bat

# -keyhook
START "" "C:\Program Files\VcXsrv\vcxsrv.exe" -keyhook -multimonitors -wgl -nodecoration +xinerama -ac -clipboard -primary

wsl --distribution Arch --user oke zsh -c "source ~/.zshrc; cd ~; dis 3; i3"

call %userprofile%\komorebi.bat
