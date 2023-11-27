#!/usr/bin/bash
set -euo pipefail

reset=0
disk=/dev/nvme0n1p2
volume_group="OkesVG"

reset() {
        swapon -s | grep "$(realpath /dev/mapper/${volume_group}-swap)" &> /dev/null && \
                swapoff "$(realpath /dev/mapper/${volume_group}-swap)"
        df | grep /mnt/boot &> /dev/null && umount /mnt/boot
        df | grep /mnt &> /dev/null && umount /mnt
        [[ -e /dev/mapper/${volume_group}-root ]] && cryptsetup close ${volume_group}-root
        [[ -e /dev/mapper/${volume_group}-swap ]] && cryptsetup close ${volume_group}-swap
        [[ -e /dev/mapper/root ]] && cryptsetup close root
}

# read arguments
opts=$(getopt \
  --longoptions "reset" \
  --options "r" \
  -- "$@"
)
eval set --$opts

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reset | -r)
      reset=1
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

[[ "${reset}" -eq 1 ]] && reset
[[ -e /dev/mapper/root ]] || cryptsetup open "${disk}" root
vgchange -ay ${volume_group}
# sleep 2
df | grep /mnt &> /dev/null || mount /dev/mapper/${volume_group}-root /mnt
df | grep /mnt/boot &> /dev/null || mount /dev/nvme0n1p1 /mnt/boot
swapon -s | grep "$(realpath /dev/mapper/${volume_group}-swap)" &> /dev/null || \
        swapon /dev/mapper/${volume_group}-swap
