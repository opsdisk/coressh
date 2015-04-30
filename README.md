# coressh
Build a custom Core .iso operating system with a SSH server

#### What is the Core Project?

The [Core Project](http://distro.ibiblio.org/tinycorelinux) is a project dedicated to providing a small, minimal Linux distribution that can be configured for any number of purposes. Tiny Core is

>designed to run from a RAM copy created at boot time. Besides being fast, this protects system files from changes and ensures a pristine system on every reboot. Easy, fast, and simple renew-ability and stability is a principle goal of Tiny Core.[^1]
 
There are three main flavors in the Core suite:

* Core (9 MB) - command-line only 
* TinyCore (15 MB) - Includes a GUI, wired network support only
* CorePlus (72 MB) - Different windows managers, various keyboard layouts, and wireless support

#### Overview

This tutorial provides a walkthrough of how to build a custom ~13 MB Core .iso operating system with a Secure Shell (SSH) server.  The 15 MB TinyCore will be used as the operating system and platform to create and configure the Core base .iso.  

The goal is to have a customized Core .iso that can be booted into using virtualization software, such as VMware, in mere seconds and is completely memory resident.  The operating system is not installed onto a hard drive.  The purpose of this tutorial is to set the stage for the next one, which will be about SSH tunneling through a single and multiple servers for the purpose of protecting Internet traffic on public networks, penetration testing, or accessing your home network.  

The resulting Core SSH server is perfect for practicing tunneling concepts because it is lightweight, memory-resident, and multiple SSH servers can be spun up in seconds.  The install script and pre-configured coressh.iso files are available on the Opsdisk Github repository here: https://github.com/opsdisk/coressh.

Pull requests, suggestions, and improvements are always welcome through our [contact](http://www.opsdisk.com/#contact) page or [twitter](https://twitter.com/opsdisk).

#### Warning
The primary purpose of the tutorial is to create a lightweight SSH server.  No hardening or security best practices (denying root logins, using pre-shared keys) have been implemented with the configuration of the SSH server.  **You should use the core_install.sh script to generate your own SSH host keys if you are paranoid and don't want to use the pre-configured coressh.iso provided on Github.**  If you just want to set up a quick SSH lab and are not concerned about security, then the pre-configured coressh.iso is OK.  

#### General Flow
Below is the general flow of building a custom Core .iso:

* Boot into the Tiny Core .iso operating system
* Install OpenSSH and ezremaster packages.  OpenSSH is the SSH server and [ezremaster](http://wiki.tinycorelinux.net/wiki:remastering_with_ezremaster) is used to create custom .iso files.
* Pull down core\_install.sh file from the Opsdisk coressh repository or a local web server to configure the server. This script will pull down the [Core-current.iso](http://distro.ibiblio.org/tinycorelinux/6.x/x86/release/Core-current.iso) to customize, edit a couple of files, and create the Core .iso using ezremaster.
* Pull the customized Core .iso file off the Virtual Machine through SFTP.
* Boot the coressh.iso as a virtual machine.

#### Setting Up the Build Platform
This walkthrough uses VMware Workstation 11 as the virtualization software.  Your mileage may vary with other virtualization software versions and software.

1) Download the [TinyCore](http://distro.ibiblio.org/tinycorelinux/6.x/x86/release/TinyCore-current.iso) .iso file.

2) Create the TinyCore VM with the following characteristics:

* Install from the TinyCore-current.iso file
* Guest operating system is "Other Linux 3.x kernel"
* Virtual machine name: "TinyCore"
* Maximum disk size: .001 GB; Store virtual disk as a single file
* Customize Hardware: 256 MB Memory, 1 processor, bridged Network Adapter, uncheck the "Connect at power on" for USB, sound card, and printer
* Power on the virtual machine

####  Creating the Customized Core .iso
After powering on the virtual machine, select the first boot option "Boot TinyCore". After the operating system loads, click on the terminal icon at the bottom on the far right. At this point, you must hand jam commands into the terminal because SSH and VMware Tools are not installed for easy copy/paste.

```bash
# Ensure you box has an IP address and that DNS works:
ifconfig
ping yahoo.com -c 2

# Install openssl to retrieve HTTPS file from GitHub
tce-load -iw openssl-1.0.1.tcz 

# Pull down core_install.sh script
wget https://github.com/opsdisk/coressh/raw/master/core_install.sh -P /tmp

# Mark script as executable
sudo chmod +x /tmp/core_install.sh

# Remove potential DOS line breaks
dos2unix /tmp/core_install.sh

# Execute the install script
/tmp/core_install.sh
```

From this point on, the script will take care of the rest.  It will prompt you to change the passwords for the tc and root user accounts. Below are the credentials for the pre-configured coressh.iso SSH server:

```
user: tc
password: masterpassword

user: root
password: masterpassword
```

If you want to walkthrough the script line by line, check out the Script Walkthrough at the end of this tutorial.  Once the script completes, pull the newly created ezremaster.iso off the TinyCore VM using a SFTP compatible program, like WinSCP, Filezilla, or the linux scp command.

#### Booting Up the New Core .iso
Create a new Core VM with the same characteristics as the TinyCore VM, except you can tweak the memory down to 128 MB (try 64 MB first and see if it crashes out).
 
    * Install from the coressh.iso file
    * Guest operating system is "Other Linux 3.x kernel"
    * Virtual machine name: "CoreSSH"
    * Maximum disk size: .001 GB; Store virtual disk as a single file
    * Customize Hardware: 128 MB Memory, 1 processor, bridged Network Adapter, uncheck the "Connect at power on" for USB, sound card, and printer
    * Power on the virtual machine

#### Conclusion
This tutorial walks you through creating a minimal Core SSH server that will be used in the next series covering SSH tunneling techniques and tips for the purpose of protecting Internet traffic on public networks, penetration testing, or accessing your home network.  All of the code and files can be found on the Opsdisk Github repository here: https://github.com/opsdisk/coressh

#### Script Walkthrough

Install OpenSSH and ezremaster

```bash
tce-load -iw openssh.tcz ezremaster.tcz
```

Start the SSH server

```bash
sudo /usr/local/etc/init.d/openssh start
```

Download the Core-current.iso file to /tmp

```bash
wget http://distro.ibiblio.org/tinycorelinux/6.x/x86/release/Core-current.iso -P /tmp
```

For the ezremaster walkthrough, click on the ezremaster icon (looks like a CD with "ez" on it) at the bottom of the screen.  Select these options:

```bash
read -p "Open ezremaster. Click on the ezremaster icon (looks like a CD with 'ez' on it) at the bottom of the screen."
read -p "Use ISO Image, specifying the /tmp/Core-current.iso file"
read -p "Next, Next"
read -p "Click load under the 'Extract TCZ in to initrd'"
read -p "Remove everything except openssh.tcz"
read -p "Next until you can Create ISO (BUT DON'T CREATE ISO YET)"
read -p "Press Enter to continue..."
```

Edit the isolinux.cfg file to change the boot timeout from 300 (30 seconds) to 10 (1 second).

```bash
sudo cp /tmp/ezremaster/image/boot/isolinux/isolinux.cfg /tmp/ezremaster/image/boot/isolinux/isolinux.cfg.backup
sudo sed -i 's/timeout 300/timeout 10/' /tmp/ezremaster/image/boot/isolinux/isolinux.cfg
```

**isolinux.cfg** contents

    display boot.msg
    default microcore
    label microcore
        kernel /boot/vmlinuz
        initrd /boot/core.gz
        append loglevel=3

    label mc
        kernel /boot/vmlinuz
        append initrd=/boot/core.gz loglevel=3
    implicit 0	
    prompt 1	
    timeout 10
    F1 boot.msg
    F2 f2
    F3 f3
    F4 f4

Add the SSH host keys that were generated when TinyCore installed SSH.  Not required, but otherwise every reboot will generate new keys. **You should use the core_install.sh script to generate your own host keys if you are paranoid and don't want to use the pre-configured coressh.iso provided on Github.**

```bash
sudo cp -f /usr/local/etc/ssh/ssh_host_* /tmp/ezremaster/extract/usr/local/etc/ssh
```
Edit the SSH server configuration
    
```bash
sudo cp /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config.backup

# Allow root to login
sudo sed -i 's/#PermitRootLogin/PermitRootLogin/' /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config

# Allows reverse SSH tunnels (-R option) to listen on interfaces besides 127.0.0.1
sudo sed -i 's/#GatewayPorts no/GatewayPorts yes/' /tmp/ezremaster/extract/usr/local/etc/ssh/sshd_config
```

Ensure the correct file permissions for the SSH host keys

```bash
sudo chown root /tmp/ezremaster/extract/usr/local/etc/ssh/ssh_host*
sudo chmod 644 /tmp/ezremaster/extract/usr/local/etc/ssh/ssh_host*pub
sudo chmod 600 /tmp/ezremaster/extract/usr/local/etc/ssh/ssh_host*key
```
Start the SSH server on boot

```bash
sudo cp /tmp/ezremaster/extract/opt/bootlocal.sh /tmp/ezremaster/extract/opt/bootlocal.sh.backup
sudo echo "/usr/local/etc/init.d/openssh start" >> /tmp/ezremaster/extract/opt/bootlocal.sh    
```

**bootlocal.sh** contents:

```bash
#!/bin/sh
# put other system startup commands here
/usr/local/etc/init.d/openssh start
```

Give the "tc" user a password

```bash
passwd tc
```

Change root user password

```bash
sudo passwd root
```
Copy the /etc/shadow & /etc/passwd files (which have the new tc and root passwords) from the current TinyCore operating system to the new Core build

```bash
sudo cp -f /etc/shadow /tmp/ezremaster/extract/etc/shadow
sudo cp -f /etc/passwd /tmp/ezremaster/extract/etc/passwd
```

Create the final .iso file using ezremaster.  The final location is /tmp/ezremaster/ezremaster.iso

```bash
read -p "Now click on Create ISO...script is done. File location: /tmp/ezremaster/ezremaster.iso"  
```
    
[^1]: http://distro.ibiblio.org/tinycorelinux/concepts.html


