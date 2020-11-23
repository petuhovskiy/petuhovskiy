#!/bin/bash
set -e

# check efi mode
ls /sys/firmware/efi/efivars

# update time
timedatectl set-ntp true
timedatectl status

# partition disk
echo 'Disk before:'
fdisk -l

parted /dev/sda 'mklabel gpt'
echo 'Formatted disk:'
fdisk -l

parted /dev/sda 'mkpart "EFI system partition" fat32 1MiB 261MiB'
parted /dev/sda 'set 1 esp on'
parted /dev/sda 'mkpart "dniwe" ext4 261MiB 100%'

# check if everything ok
fdisk -l

# format partitions
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# mount
mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi

# install
pacstrap /mnt base linux linux-firmware vim nano zsh

genfstab -U /mnt >> /mnt/etc/fstab
echo '/mnt/etc/fstab::'
cat /mnt/etc/fstab

### CHROOT
cat > /mnt/post_install.sh <<-END
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
    hwclock --systohc
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "ARTHUR-ARCH" > /etc/hostname

    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1" >> /etc/hosts
    echo "127.0.1.1 ARTHUR-ARCH.localdomain ARTHUR-ARCH" >> /etc/hosts

		echo '/etc/hosts::'
		cat /eth/hosts

    # TODO: network

    passwd

    # boot loader
    pacman -S refind
    refind-install
END

arch-chroot /mnt /bin/bash post_install.sh