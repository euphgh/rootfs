#!/bin/bash

rm -f $1

cat <<EOF >> $1
dir /bin 755 0 0
dir /etc 755 0 0
dir /etc/init.d 755 0 0
dir /dev 755 0 0
dir /lib 755 0 0
dir /proc 755 0 0
dir /sbin 755 0 0
dir /sys 755 0 0
dir /tmp 755 0 0
dir /usr 755 0 0
dir /mnt 755 0 0
dir /usr/bin 755 0 0
dir /usr/lib 755 0 0
dir /usr/sbin 755 0 0
dir /var 755 0 0
dir /var/tmp 755 0 0
dir /root 755 0 0
dir /var/log 755 0 0

nod /dev/console 644 0 0 c 5 1
nod /dev/null 644 0 0 c 1 3
EOF

cat <<EOF >> $1
file /etc/fstab      ${INITRAMFS_ROOT}/etc/fstab 755 0 0
file /etc/motd       ${INITRAMFS_ROOT}/etc/motd 755 0 0
file /etc/init.d/rcS ${INITRAMFS_ROOT}/etc/init.d/rcS 755 0 0
file /bin/busybox    ${INITRAMFS_ROOT}/bin/busybox 755 0 0
slink /init /bin/busybox 755 0 0
EOF

########################################################################

# Recursively add files and subdirectories under ${INITRAMFS_ROOT}/my-dir to ramfs

target_directory="${INITRAMFS_ROOT}/apps"
mkdir -p ${target_directory}
log=$1

function process_directory {
  local dir="$1"

  for item in "$dir"/*; do
    if [ -d "$item" ]; then
      # process current directory
      local dirname=$(basename "$item")
      local path=${item#${INITRAMFS_ROOT}}
      local permissions="755 0 0"
      echo "dir $path $permissions" >> $log
      # process subdirectories
      process_directory "$item" 
    elif [ -f "$item" ]; then
      # process file
      local permissions="755 0 0"
      local path=${item#${INITRAMFS_ROOT}}
      echo "file $path $item $permissions" >> $log
    fi
  done
}

if [ $# -ne 1 ]; then
  echo "Usage: $0 DIRECTORY"
  exit 1
fi

if [ ! -d "$target_directory" ]; then
  echo "not find directory: $target_directory"
  exit 1
fi

# process user-defined directories
dir_permissions="755 0 0"
abs_path=$(realpath $target_directory)
ramfs_path=${abs_path#${INITRAMFS_ROOT}}
echo "dir $ramfs_path $dir_permissions" >> $log

process_directory "$target_directory"
