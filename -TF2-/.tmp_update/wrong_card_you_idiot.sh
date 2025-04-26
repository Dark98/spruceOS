#!/bin/sh

CURRENT_TF1=/mnt/sdcard
CURRENT_TF2=/media/sdcard0
SYSTEM_DEV="/dev/mmcblk1p1"
DATA_DEV="/dev/mmcblk2p1"

# Give the system some time to enumerate SD cards
sleep 2

# Kill updater if running
pkill -f updater 2>/dev/null

# Wait for both devices to show up
[ ! -b "$SYSTEM_DEV" ] && echo "Waiting for SYSTEM_DEV..." && sleep 1
[ ! -b "$DATA_DEV" ] && echo "Waiting for DATA_DEV..." && sleep 1

# Attempt to mount system card if not already mounted
if ! mountpoint -q "$CURRENT_TF2" && [ -b "$SYSTEM_DEV" ]; then
    mkdir -p "$CURRENT_TF2"
    mount "$SYSTEM_DEV" "$CURRENT_TF2"
fi

# Double-check paths now
if [ -f "$CURRENT_TF2/spruce/scripts/runtime.sh" ]; then
    umount "$CURRENT_TF1" 2>/dev/null
    umount "$CURRENT_TF2" 2>/dev/null
    mount "$SYSTEM_DEV" "$CURRENT_TF2"
    mount "$DATA_DEV" "$CURRENT_TF1"
    echo "runtime.sh was found on TF2. Cards were swapped." > /mnt/SDCARD/remount.log

elif [ -f "$CURRENT_TF1/spruce/scripts/runtime.sh" ]; then
    echo "runtime.sh found on TF1, proceeding as-is." > /mnt/SDCARD/remount.log

else
    echo "runtime.sh not found on either card. Shutting down." > /mnt/SDCARD/remount.log
    poweroff
fi

# Final run step
cd /mnt/SDCARD/spruce/scripts 2>/dev/null && ./runtime.sh
