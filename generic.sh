#!/bin/sh

TYPE='generic'
#TYPE='alternative'

# ... (Table with architecture, loader, and glibc versions)

unset LD_LIBRARY_PATH
unset LD_PRELOAD

ARCH=armv7sf-k3.2
LOADER=ld-linux.so.3
GLIBC=2.27

# Checking for prerequisites and creating folders
echo 'Info: Checking for prerequisites and creating folders...'
if [ -d /tmp/mnt/sdb1 ]; then
    echo 'Warning: Folder /tmp/mnt/sdb1 exists!'
else
    mkdir /tmp/mnt/sdb1
fi
# no need to create many folders. entware-opt package creates most
for folder in bin etc lib/opkg tmp var/lock; do
    if [ -d "/tmp/mnt/sdb1/$folder" ]; then
        echo "Warning: Folder /tmp/mnt/sdb1/$folder exists!"
        echo 'Warning: If something goes wrong please clean /tmp/mnt/sdb1 folder and try again.'
    else
        mkdir -p /tmp/mnt/sdb1/$folder
    fi
done

# Opkg package manager deployment
echo 'Info: Opkg package manager deployment...'
URL=http://bin.entware.net/${ARCH}/installer
wget $URL/opkg -O /tmp/mnt/sdb1/bin/opkg
chmod 755 /tmp/mnt/sdb1/bin/opkg
wget $URL/opkg.conf -O /tmp/mnt/sdb1/etc/opkg.conf

# Basic packages installation
echo 'Info: Basic packages installation...'
/tmp/mnt/sdb1/bin/opkg update
if [ $TYPE = 'alternative' ]; then
    /tmp/mnt/sdb1/bin/opkg install busybox
fi
/tmp/mnt/sdb1/bin/opkg install entware-opt

# Fix for multiuser environment
chmod 777 /tmp/mnt/sdb1/tmp

# Copying configuration files and creating symlinks
for file in passwd group shells shadow gshadow; do
    if [ $TYPE = 'generic' ]; then
        if [ -f /etc/$file ]; then
            ln -sf /etc/$file /tmp/mnt/sdb1/etc/$file
        else
            [ -f /tmp/mnt/sdb1/etc/$file.1 ] && cp /tmp/mnt/sdb1/etc/$file.1 /tmp/mnt/sdb1/etc/$file
        fi
    else
        if [ -f /tmp/mnt/sdb1/etc/$file.1 ]; then
            cp /tmp/mnt/sdb1/etc/$file.1 /tmp/mnt/sdb1/etc/$file
        fi
    fi
done

[ -f /etc/localtime ] && ln -sf /etc/localtime /tmp/mnt/sdb1/etc/localtime

# Final messages
echo 'Info: Congratulations!'
echo 'Info: If there are no errors above then Entware was successfully initialized.'
echo 'Info: Add /tmp/mnt/sdb1/bin & /tmp/mnt/sdb1/sbin to $PATH variable'
echo 'Info: Add "/tmp/mnt/sdb1/etc/init.d/rc.unslung start" to startup script for Entware services to start'
if [ $TYPE = 'alternative' ]; then
    echo 'Info: Use ssh server from Entware for better compatibility.'
fi
echo 'Info: Found a Bug? Please report at https://github.com/Entware/Entware/issues'
