#!/bin/bash
#
# Enable SSH (dropbear) on a Netgear Orbi RBR50. Listens on your internal interface, not exposed to the internet.
#
# 2020-11-02: In general the system does not allow for persistent changes across reboot. There is though a filesystem
# where you can persist changes: /mnt/bitdefender, that filesystem stores the Orbi's bit defender installation.
#
# This script injects itself into the boot process of the bit defender software
# via /mnt/bitdefender/bin/bd_procd and utilizes it's filesystem to store software and configuration. 
#
# For information on using this script, see: https://github.com/mglantz/ssh-rbr50
# 
# sudo@redhat.com, 2020

# Get the IP for the internal br0 interface. First wait until we see it. Loop for 6 minutes.
loop=360
while true; do
        if [ "$loop" == "181" ]; then
                echo "Error: no internal IP found."
                exit 1
        fi
        sleep 1
        if ifconfig br0|grep "inet addr:" >/dev/null; then
                sleep 3
                break
        fi
done

INTERNAL_IP=$(ip a l br0|grep -v inet6|grep inet|cut -d' ' -f6|sed 's/\/.*//')

# Check if someone ran this script before
if [ ! -f /sbin/dropbear ]; then
        # Go to the filesystem which allows us to persist changes across reboot
        cd /mnt/bitdefender
        # Check if the dropbear SSH software has been installed yet
        if [ ! -f /mnt/bitdefender/usr/sbin/dropbear ]; then             
                read -p "First time you run this script, it needs to be done manually from a terminal. Press enter." next
                echo "Enter password for the root admin user, which you use to access the system."
                passwd root
                # If password reset is successful, copy passwd/shadow files to a location where we can persist changes
                if [ "$?" -eq 0 ]; then
                        cp /etc/passwd /mnt/bitdefender/.passwd.old
                        cp /etc/shadow /mnt/bitdefender/.shadow.old
                        cp /etc/passwd /mnt/bitdefender/.passwd
                        cp /etc/shadow /mnt/bitdefender/.shadow
                fi
                # Download and extract dropbear SSH server
                wget --no-check-certificate https://github.com/whiteskin/openwrt-imagebuilder-ipq806x/raw/master/packages/base/dropbear_2015.67-1_ipq806x.ipk
                tar xvzf dropbear_2015.67-1_ipq806x.ipk
                tar xvzf data.tar.gz
                chmod a+rx /mnt/bitdefender/usr/bin/* /mnt/bitdefender/usr/sbin/*
        fi
        
        # If we have persisted our passwords, copy them to the emphemeral filesystem, otherwise error.
        if [ ! -f /mnt/bitdefender/.passwd ]; then
                echo "Error: root password not set. Run below and try again:"
                echo "passwd root"
                echo "cp /etc/passwd /mnt/bitdefender/.passwd"
                echo "cp /etc/shadow /mnt/bitdefender/.shadow"
                exit 1
        else
                cp /mnt/bitdefender/.passwd /etc/passwd
                cp /mnt/bitdefender/.shadow /etc/shadow
        fi
        
        # If we have not injected the start script into the bit defender start script, do so.
        if ! grep start_ssh /mnt/bitdefender/bin/bd_procd >/dev/null; then
                sed -i -e '/start_services() {/a sh \/mnt\/bitdefender\/start_ssh'a /mnt/bitdefender/bin/bd_procd
        fi

        # At boot, there is no dropbear config directory (where keys are stored), so create it
        if [ ! -d /etc/dropbear ]; then
                mkdir /etc/dropbear
        fi
        
        # If someone saved the dropbear key file, copy it to the emphemeral filesystem at boot
        if [ -f /mnt/bitdefender/dropbear_rsa_host_key ]; then
                cp /mnt/bitdefender/dropbear_rsa_host_key /etc/dropbear
        fi
        
        # Copy dropbear binaries to the emphemeral filesystem
        cp -Rp /mnt/bitdefender/usr/bin/* /bin/
        cp -Rp /mnt/bitdefender/usr/sbin/* /sbin/
        
        # Start dropbear, generate keyfiles if they don't exist and only listen to the internal interface.
        dropbear -R -p $INTERNAL_IP:22 &
fi

# If someone runs this multiple times, manually, check for started dropbear.
if pidof dropbear >/dev/null; then
        echo "dropbear running"
else
        # Start dropbear, generate keyfiles if they don't exist and only listen to the internal interface.
        dropbear -R -p $INTERNAL_IP:22 &
fi
