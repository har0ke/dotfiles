#!/usr/bin/bash
set -euo pipefail

script_dir="$(dirname -- "${BASH_SOURCE[0]}" )"

"${script_dir}/mount.sh"

sudo arch-chroot /mnt pacman -Suy
