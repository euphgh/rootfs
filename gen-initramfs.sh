#!/bin/bash

rm -f $1

INITRAMFS_ROOT=$(dirname $(realpath $1))/initramfs

cat <<EOF >> $1
dir /bin 755 0 0
dir /dev 755 0 0
dir /proc 755 0 0
dir /sbin 755 0 0
dir /sys 755 0 0
dir /tmp 755 0 0
dir /usr 755 0 0
dir /usr/bin 755 0 0
dir /usr/lib 755 0 0
dir /usr/sbin 755 0 0

nod /dev/console 644 0 0 c 5 1
nod /dev/null 644 0 0 c 1 3
EOF

cat <<EOF >> $1
file /bin/busybox ${INITRAMFS_ROOT}/bin/busybox 755 0 0
slink /init /bin/busybox 755 0 0
EOF

########################################################################

INITRAMFS_TXT=$1

function process_directory_impl {
  local dir="$1"

  for item in "$dir"/*; do
    if [ -d "$item" ]; then
      # process current directory
      local dirname=$(basename "$item")
      local path=${item#${INITRAMFS_ROOT}}
      local permissions="755 0 0"
      echo "dir $path $permissions" >> $INITRAMFS_TXT
      # process subdirectories
      process_directory_impl "$item" 
    elif [ -f "$item" ]; then
      # process file
      local permissions="755 0 0"
      local path=${item#${INITRAMFS_ROOT}}
      echo "file $path $item $permissions" >> $INITRAMFS_TXT
    fi
  done
}

function process_directory {
  if [ $# -ne 1 ]; then
    echo "Usage: $0 DIRECTORY"
    exit 1
  fi
 
  if [ ! -d "$1" ]; then
    echo "not find directory: $1"
    exit 1
  fi
 
  # process user-defined directories
  dir_permissions="755 0 0"
  abs_path=$(realpath $1)
  ramfs_path=${abs_path#${INITRAMFS_ROOT}}
  echo "dir $ramfs_path $dir_permissions" >> $INITRAMFS_TXT
  process_directory_impl $1
}

process_directory "${INITRAMFS_ROOT}/etc"
process_directory "${INITRAMFS_ROOT}/apps"

