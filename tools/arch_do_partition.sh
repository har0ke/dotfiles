#!/usr/bin/bash

set -euo pipefail

DISK=NOTFOUND

# read arguments
opts=$(getopt \
  --longoptions "disk:" \
  --options "d:" \
  -- "$@"
)

eval set --$opts

while [[ $# -gt 0 ]]; do
  case "$1" in
    --disk | -d)
      DISK="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

PART_BOOT="${DISK}p1"
PART_LVM="${DISK}p2"
VG_NAME="vg0"

function assert() (
    set +euo pipefail
    "${@:2}" &> /dev/null
    if [[ "$?" -ne 0 ]]; then
        echo "$1"
        exit 1
    fi
)

function clean() (
    set +euo pipefail
    swapoff "/dev/${VG_NAME}/swap"
    umount "/mnt/boot"
    umount "/mnt/"
    cryptsetup close "${VG_NAME}-root"
    cryptsetup close "${VG_NAME}-swap"
    cryptsetup close "${VG_NAME}"
    cryptsetup close cryptlvm
    true
)

assert "EFI Variables not set: Are you booted into UEFI?" ls /sys/firmware/efi/efivars

clean

echo -e 'size=512M, type=U\n size=+, type=L\n' | sfdisk "${DISK}"
sync

mkfs.fat -F32 "${PART_BOOT}"

cryptsetup luksFormat "${PART_LVM}"
cryptsetup open "${PART_LVM}" cryptlvm

pvcreate /dev/mapper/cryptlvm
pvcreate /dev/mapper/cryptlvm
vgcreate "${VG_NAME}" /dev/mapper/cryptlvm
lvcreate -L 8G "${VG_NAME}" -n swap
lvcreate -l 100%FREE "${VG_NAME}" -n root
lvreduce -L -256M "${VG_NAME}/root"

mkfs.ext4 "/dev/${VG_NAME}/root"
mkswap "/dev/${VG_NAME}/swap"

mount "/dev/${VG_NAME}/root" /mnt
mount --mkdir "${PART_BOOT}" /mnt/boot
swapon "/dev/${VG_NAME}/swap"
