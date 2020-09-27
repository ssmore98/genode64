#!/bin/sh
export SECTORS=$((1024*1024*2))
export SKIP=2048
export ENDSECTOR=2097118
export GROOT=/genode/genode64
export UBOOT=/genode/u-boot
export ROM=$UBOOT/u-boot.rom
export ACPI=/usr/share/qemu-kvm/q35-acpi-dsdt.aml
export QEMU="qemu-system-x86_64  -machine q35 -bios $ROM -serial mon:stdio -acpitable data=$ACPI -usb -m 8G"
# docker exec bb318fb51d67 make -C $GROOT/build/x86_64 clean
# docker exec bb318fb51d67 make -C $GROOT/build/x86_64 run/sell4
export IMGFILE=$GROOT/sell4.img
dd if=/dev/zero of=$IMGFILE bs=1M count=1024
export PARTED="parted -s $IMGFILE"
$PARTED mktable gpt
$PARTED mkpart SELL4 ext4 "$SKIP"s "$ENDSECTOR"s
$PARTED print
export LOOP=`sudo losetup --offset $((512*$SKIP)) --sizelimit $(($ENDSECTOR*512-$SKIP*512)) --show -f $IMGFILE`
sudo mkfs.ext4 -F -L SELL4 -q -v -D $LOOP
$PARTED print
sudo e2mkdir $LOOP:/boot
sudo e2cp boot/config.txt $LOOP:/boot
sudo losetup -d $LOOP
# cp $GROOT/tool/boot/bender $GROOT/iso/boot
# cp $GROOT/build/x86_64/bin/sell4-pc $GROOT/iso/boot
# grub2-mkrescue -o $GROOT/os.iso $GROOT/iso
# qemu-system-x86_64 -cpu Nehalem,-vme,+pdpe1gb,-xsave,-xsaveopt,-xsavec,-fsgsbase,-invpcid,enforce -serial mon:stdio -enable-kvm -cdrom $GROOT/os.iso
$QEMU -device ide-drive,drive=ide0 -drive file=$IMGFILE,id=ide0,index=0,media=disk,if=ide,format=raw
