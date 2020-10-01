#!/bin/sh
export SECTORS=$((1024*1024*2))
export SKIP=2048
export ENDSECTOR=2097118
export GROOT=/genode/genode64
export BUILD=$GROOT/build/x86_64
export KERNEL=$BUILD/var/libcache/kernel-sell4-pc/kernel.elf
export UBOOT=/genode/u-boot
export ROM=$UBOOT/u-boot.rom
export ACPI=/usr/share/qemu-kvm/q35-acpi-dsdt.aml
export QEMU="qemu-system-x86_64 -machine q35 -serial mon:stdio -acpitable data=$ACPI -usb -mem-path /dev/hugepages -m 1G"
ssh 192.168.122.61 make -C $GROOT/build/x86_64 clean
ssh 192.168.122.61 make -C $GROOT/build/x86_64 run/sell4
# docker exec bb318fb51d67 make -C $GROOT/build/x86_64 clean
# docker exec bb318fb51d67 make -C $GROOT/build/x86_64 run/sell4
#### #### export IMGFILE=$GROOT/sell4.img
#### #### dd if=/dev/zero of=$IMGFILE bs=1M count=1024
#### #### export PARTED="parted -s $IMGFILE"
#### #### $PARTED mktable gpt
#### #### $PARTED mkpart SELL4 ext4 "$SKIP"s "$ENDSECTOR"s
#### #### $PARTED set 1 boot on
#### #### $PARTED print
#### #### export LOOP=`sudo losetup --offset $((512*$SKIP)) --sizelimit $(($ENDSECTOR*512-$SKIP*512)) --show -f $IMGFILE`
#### #### sudo mkfs.ext4 -F -L SELL4 -q -v -D $LOOP
#### #### $PARTED print
#### #### sudo e2mkdir $LOOP:/boot
#### #### sudo e2cp boot/config.txt $LOOP:/boot
#### #### sudo e2cp $UBOOT/u-boot.bin $LOOP:/boot
#### #### sudo e2cp $GROOT/build/x86_64/bin/sell4-pc $LOOP:/boot
#### #### sudo e2cp /boot/vmlinuz-3.10.0-862.el7.x86_64 $LOOP:/boot
#### #### sudo e2cp /boot/symvers-3.10.0-862.el7.x86_64.gz $LOOP:/boot
#### #### sudo e2cp /boot/initramfs-3.10.0-862.el7.x86_64.img $LOOP:/boot
#### #### sudo losetup -d $LOOP
# cp $GROOT/tool/boot/bender $GROOT/iso/boot
# grub2-mkrescue -o $GROOT/os.iso $GROOT/iso
# qemu-system-x86_64 -cpu Nehalem,-vme,+pdpe1gb,-xsave,-xsaveopt,-xsavec,-fsgsbase,-invpcid,enforce -serial mon:stdio -enable-kvm -cdrom $GROOT/os.iso
#$QEMU -device ahci,id=ahci0 -device ide-hd,drive=ahci0,bus=ahci0.0 -drive file=$IMGFILE,id=ahci0,index=0,media=disk,format=raw
# $QEMU -device nvme,drive=nvme0,serial=nvme0 -drive file=$IMGFILE,id=nvme0,if=none
# $QEMU -sda $IMGFILE
# $QEMU -drive file=$IMGFILE,index=0,media=disk
# $QEMU -device virtio-scsi-pci,id=scsi0 -device scsi-hd,drive=drive0,bus=scsi0.0,channel=0,scsi-id=0,lun=0 -drive file=$IMGFILE,if=none,id=drive0
# $QEMU -device usb-ehci -device usb-storage,drive=drive0,bootindex=0 -drive file=$IMGFILE,if=none,id=drive0
# qemu-system-x86_64 -cpu kvm64,-vme,+pdpe1gb,-xsave,-xsaveopt,-xsavec,-fsgsbase,-invpcid,enforce -serial mon:stdio -m 8G -kernel $GROOT/build/x86_64/bin/sell4-pc
$QEMU -enable-kvm -kernel $KERNEL -cpu qemu64
