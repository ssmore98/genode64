#!/bin/sh
export SECTORS=$((256*1024*2))
export SKIP=2048
export ENDSECTOR=2097118
export GROOT=/genode/genode64
export BUILD=$GROOT/build/x86_64
export KERNEL=$BUILD/var/libcache/kernel-sell4-pc/kernel.elf
export KERNEL_1=$GROOT/boot/boot/sel4-pc
# export UBOOT=/genode/u-boot
# export ROM=$UBOOT/u-boot.rom
export ROM=/usr/share/u-boot.git/x64/qemu-pc/u-boot.rom
export ACPI=/usr/share/qemu-kvm/q35-acpi-dsdt.aml
export QEMU="qemu-system-x86_64 -machine q35 -serial mon:stdio -acpitable data=$ACPI -usb -mem-path /dev/hugepages -m 1G -bios $ROM"

ssh 192.168.122.61 make -C $GROOT/build/x86_64 clean
ssh 192.168.122.61 make -C $GROOT/build/x86_64 run/sell4

export KERNELBIN=$GROOT/sell4-pc.bin
objcopy -O binary $KERNEL $KERNELBIN

export UBOOTFILE=$GROOT/sell4-uboot.img
mkimage -f $GROOT/sell4.its $UBOOTFILE

export IMGFILE=$GROOT/sell4.img
dd if=/dev/zero of=$IMGFILE bs=1M count=1024
export PARTED="parted -s $IMGFILE"
$PARTED mktable gpt
$PARTED mkpart SELL4 ext4 "$SKIP"s "$ENDSECTOR"s
$PARTED set 1 boot on
$PARTED print
export LOOP=`sudo losetup --offset $((512*$SKIP)) --sizelimit $(($ENDSECTOR*512-$SKIP*512)) --show -f $IMGFILE`
sudo mkfs.ext4 -F -L SELL4 -q -v -D $LOOP
$PARTED print

sudo e2cp $UBOOTFILE $LOOP:/
sudo e2mkdir $LOOP:/boot
sudo e2cp boot/config.txt $LOOP:/boot
sudo e2cp $KERNEL $LOOP:/boot
sudo e2cp /boot/vmlinuz-3.10.0-862.el7.x86_64 $LOOP:/boot
sudo e2cp /boot/symvers-3.10.0-862.el7.x86_64.gz $LOOP:/boot
sudo e2cp /boot/initramfs-3.10.0-862.el7.x86_64.img $LOOP:/boot

sudo losetup -d $LOOP

$QEMU -device usb-ehci -device usb-storage,drive=drive0,bootindex=0 -drive file=$IMGFILE,if=none,id=drive0
