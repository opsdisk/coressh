#!/bin/sh
# This script is used to create a custom Core .iso operating system
# with a running SSH server. The core iso is created from
# a running TinyCore instance, with some of the settings transferred 
# to the new Core .iso. 
# MIT License
# Opsdisk LLC | opsdisk.com

#################################
# Setting up the build platform #
#################################
# Install from the TinyCore-current.iso file
# Guest operating system is "Other Linux 3.x kernel"
# Virtual machine name: "TinyCore"
# Maximum disk size: .001 GB; Store virtual disk as a single file
# Customize Hardware: 256 MB Memory, 1 processor, bridged Network Adapter, uncheck the "Connect at power on" for USB, sound card, and printer
# Power on the virtual machine

# These commands are run on target, not from the script.  
# Ensure you box has an IP address and that DNS works
#    ifconfig
#    ping yahoo.com -c 2
# Install openssl to retrieve HTTPS file from GitHub
#    tce-load -iw openssl-1.0.1.tcz 
# Pull down core_install.sh script
#    wget https://github.com/opsdisk/coressh/raw/master/core_install.sh -P /tmp
# Mark script as executable
#    sudo chmod +x /tmp/core_install.sh
# Remove potential DOS line breaks
#    dos2unix /tmp/core_install.sh
# Execute the install script
#    /tmp/core_install.sh 

# Install openssh and ezremaster
tce-load -iw openssh.tcz ezremaster.tcz        
           
# Start the SSH server
sudo /usr/local/etc/init.d/openssh start

# wget the Core-current.iso file to /tmp
wget http://distro.ibiblio.org/tinycorelinux/6.x/x86/release/Core-current.iso -P /tmp

# ezremaster walkthrough
read -p "Open ezremaster. Click on the ezremaster icon (looks like a CD with 'ez' on it) at the bottom of the screen."
read -p "Use ISO Image, specifying the /tmp/Core-current.iso file"
read -p "Next, Next"
read -p "Click load under the 'Extract TCZ in to initrd'"
read -p "Remove everything except openssh.tcz"
read -p "Next until you can Create ISO (BUT DON'T CREATE ISO YET)"
read -p "Press Enter to continue..."
    
###########################
# Modifying the new build #
###########################

# Edit the isolinux.cfg file to change the boot timeout from 300 (30 seconds) to 10 (1 second)
#sudo cp -f /tmp/core_install/isolinux.cfg /tmp/ezremaster/image/boot/isolinux/isolinux.cfg
sudo cp /tmp/ezremaster/image/boot/isolinux/isolinux.cfg /tmp/ezremaster/image/boot/isolinux/isolinux.cfg.backup
sudo sed -i 's/timeout 300/timeout 10/' /tmp/ezremaster/image/boot/isolinux/isolinux.cfg

# Add the SSH keys generated when TinyCore installed SSH.  Not required, but otherwise every reboot will generate new keys.
#sudo cp -f /tmp/core_install/ssh_host* /tmp/ezremaster/extract/usr/local/etc/ssh
sudo cp -f /usr/local/etc/ssh/ssh_host_* /tmp/ezremaster/extract/usr/local/etc/ssh

# Edit the SSH server configuration
#sudo cp -f /tmp/core_install/sshd_config /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config
sudo cp /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config.backup
sudo sed -i 's/#PermitRootLogin/PermitRootLogin/' /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config
sudo sed -i 's/#GatewayPorts no/GatewayPorts yes/' /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config

# Ensure the correct file permissions for the SSH keys
sudo chown root /tmp/ezremaster/extract/usr/local/etc/ssh/ssh_host*
sudo chmod 644 /tmp/ezremaster/extract/usr/local/etc/ssh/ssh_host*pub
sudo chmod 600 /tmp/ezremaster/extract/usr/local/etc/ssh/ssh_host*key

# Start the SSH server on boot
#sudo cp -f /tmp/core_install/bootlocal.sh /tmp/ezremaster/extract/opt/bootlocal.sh 
sudo cp /tmp/ezremaster/extract/opt/bootlocal.sh /tmp/ezremaster/extract/opt/bootlocal.sh.backup
sudo echo "/usr/local/etc/init.d/openssh start" >> /tmp/ezremaster/extract/opt/bootlocal.sh

# Give the "tc" user a password
passwd tc

# Change root user password
sudo passwd root

# Copy the /etc/shadow & /etc/passwd files (which have the new tc and root passwords) from the current TinyCore operating system to the new Core build
sudo cp -f /etc/shadow /tmp/ezremaster/extract/etc/shadow
sudo cp -f /etc/passwd /tmp/ezremaster/extract/etc/passwd

read -p "Now click on Create ISO...script is done. File location: /tmp/ezremaster/ezremaster.iso"
