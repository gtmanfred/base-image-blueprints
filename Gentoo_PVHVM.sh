#!/bin/bash
echo "Download complete and executing..."
if [ -d '/mnt/gentoo/etc' ]; then exit 0; fi

curr_tty=$(tty)
echo $curr_tty
if [ $curr_tty == "/dev/tty1" ]; then echo "Launching Gentoo_PVHVM.sh"; else echo "Error - Gentoo_PVHVM.sh running already on /dev/tty1!"; exit 0; fi

# set root pass in install cd
(echo novaagentneedsunlockedrootaccountsowedeletepasswordinpost ; sleep 3; echo novaagentneedsunlockedrootaccountsowedeletepasswordinpost) | passwd

# partition and filesystem bits
parted -s /dev/sda mklabel msdos
parted -s --align=none /dev/sda mkpart primary 2048s 100%
parted /dev/sda set 1 boot on
mkfs.ext4 /dev/sda1

mount /dev/sda1 /mnt/gentoo

cd /mnt/gentoo

# grab stage3 and verify
stage3_name=$(curl ftp://mirror.rackspace.com/gentoo/releases/amd64/autobuilds/current-stage3-amd64/ | grep -iv 'content\|digest\|multilib\|x32\|hardened\|iso' | awk {'print $9'})
wget http://mirror.rackspace.com/gentoo/releases/amd64/autobuilds/current-stage3-amd64/$stage3_name
wget http://mirror.rackspace.com/gentoo/releases/amd64/autobuilds/current-stage3-amd64/$stage3_name.DIGESTS
stage3_checksum=$(head -n 2 /mnt/gentoo/*.DIGESTS|tail -n 1|awk {'print $1'})
stage3_checksum_value=$(sha512sum /mnt/gentoo/stage3-amd64-*.tar.bz2)
if [[ "$stage3_checksum_value" != *"$stage3_checksum"* ]]; then echo "Error - Checksum Mismatch"; exit 0; fi

# expand stage3 and copy resolv.conf
echo "Expanding stage3"
tar xjpf stage3-*.tar.bz2

cp -L /etc/resolv.conf /mnt/gentoo/etc/

# chroot into install
cd /mnt/gentoo
echo "Chroot into new system"
mount -t proc none /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
wget http://KICK_HOST/kickstarts/Gentoo_PVHVM-2.sh
chmod +x Gentoo_PVHVM-2.sh
chroot /mnt/gentoo /bin/bash -c "/Gentoo_PVHVM-2.sh"

rm -f /mnt/gentoo/Gentoo_PVHVM-2.sh

cd /root
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -l /mnt/gentoo{/proc,}
shutdown -h now
