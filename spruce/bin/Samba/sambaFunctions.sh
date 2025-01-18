#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh

if [ $PLATFORM = "A30" ]; then
	SMB_DIR=/mnt/SDCARD/spruce/bin/Samba
else
	SMB_DIR=/mnt/SDCARD/spruce/bin64/Samba
fi

samba_check(){
    if setting_check "samba"; then
        start_samba_process
    fi
}

start_samba_process(){
    log_message "Starting Samba..."
    
	# Set the LD_LIBRARY_PATH
	export LD_LIBRARY_PATH="$SMB_DIR/lib:$LD_LIBRARY_PATH"

	# Create necessary directories
	mkdir -p /tmp/samba/private
	mkdir -p /tmp/samba/lock
	mkdir -p /tmp/samba/run

	# Set the Samba password for the root user
	PASSWORD="happygaming"
	echo -ne "$PASSWORD\n$PASSWORD\n" | $SMB_DIR/bin/smbpasswd -c $SMB_DIR/config/smb.conf -s -a spruce

	# Start the Samba daemon
	rm /tmp/samba/run/smbd-smb.conf.pid
	LD_LIBRARY_PATH="$LD_LIBRARY_PATH" $SMB_DIR/bin/smbd -s $SMB_DIR/config/smb.conf -D
}

stop_samba_process(){
    log_message "Shutting down Samba..."
    kill $(pgrep smbd)
}
