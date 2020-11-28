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
		cat /etc/hosts

    # TODO: network

    passwd

    # network
    pamcan -S networkmanager
    systemctl enable NetworkManager.service

    # gui
    # pacman -S xorg gnome gdm
    # systemctl enable gdm.service

    # boot loader
    pacman -S refind grub efibootmgr
    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/efi
    grub-mkconfig -o /boot/grub/grub.cfg
    # refind-install
END

arch-chroot /mnt /bin/bash post_install.sh


# shutdown now
