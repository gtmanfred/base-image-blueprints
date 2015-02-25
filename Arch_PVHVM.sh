echo "Download complete and executing..."
if [ -d '/mnt/arch/etc' ]; then exit 0; fi

curr_tty=$(tty)
echo $curr_tty
if [ $curr_tty == "/dev/tty1" ]; then echo "Launching Arch_PVHVM.sh"; else echo "Error - Arch_PVHVM.sh running already on /dev/tty1!"; exit 0; fi

# set root pass in install cd
(echo novaagentneedsunlockedrootaccountsowedeletepasswordinpost ; sleep 3; echo novaagentneedsunlockedrootaccountsowedeletepasswordinpost) | passwd

export CONFIG_LABEL=Arch_PVHVM
# partition and filesystem bits
parted -s /dev/sda mklabel msdos
parted -s --align=none /dev/sda mkpart primary 2048s 100%
parted /dev/sda set 1 boot on
mkfs.ext4 /dev/sda1

mkdir /mnt/arch
mount /dev/sda1 /mnt/arch
cd /mnt/arch
bootstrap_date=$(curl ftp://mirror.rackspace.com/archlinux/iso/ | grep -iv 'archboot'| grep -iv 'latest'|awk {'print $9'}|tail -n 1|awk {'print $1'})
wget http://mirror.rackspace.com/archlinux/iso/$bootstrap_date/archlinux-bootstrap-$bootstrap_date-x86_64.tar.gz
tar -zxf archlinux*.tar.gz
mv root.x86_64/* . && rm -rf root.x86_64
rm -rf etc/resolv.conf
cp /etc/resolv.conf etc/resolv.conf
echo 'Server = http://mirror.rackspace.com/archlinux/$repo/os/$arch' > etc/pacman.d/mirrorlist

# chroot into install
echo "Chroot into new system"
mount -t proc none /mnt/arch/proc
mount --rbind /sys /mnt/arch/sys
mount --rbind /dev /mnt/arch/dev
mount --rbind /run /mnt/arch/run
wget http://KICK_HOST/Arch_PVHVM-2.sh
chmod +x Arch_PVHVM-2.sh
chroot /mnt/arch /bin/bash -c "/Arch_PVHVM-2.sh"

rm -f /mnt/arch/Arch_PVHVM-2.sh

cd /root
umount -l /mnt/arch/dev{/shm,/pts,}
umount -l /mnt/arch{/proc,/run,/sys}
shutdown -h now
