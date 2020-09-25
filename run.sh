#!/bin/sh
export GROOT=/genode/genode64
docker exec bb318fb51d67 make -C $GROOT/build/x86_64 run/sell4
cp $GROOT/tool/boot/bender $GROOT/iso/boot
cp $GROOT/build/x86_64/bin/sell4-pc $GROOT/iso/boot
grub2-mkrescue -o $GROOT/os.iso $GROOT/iso
qemu-system-x86_64 -serial mon:stdio -enable-kvm -cdrom $GROOT/os.iso
