export ARCH=i686-elf
export AR=$(ARCH)-ar
export ASM=nasm
export ASMFLAGS=-felf32
export BOCHS=bochs
export CC=$(ARCH)-gcc
export CFLAGS=-std=gnu99 -ffreestanding -O2 -I$(shell pwd)/include
QEMU=qemu-system-i386
#QEMU=qemu-system-i386 -d cpu_reset

.PHONY: all clean qemu qemu-bin bochs

all: dist/bullseye.iso

clean:
	rm -rf dist
	find . -type f -name '*.o' -delete
	find . -type f -name '*.a' -delete
	find . -type f -name '*.bin' -delete
	find . -type f -name '*.iso' -delete

src/bullseye.bin:
	$(MAKE) -C src
	grub-file --is-x86-multiboot src/bullseye.bin

dist/bullseye.iso: src/bullseye.bin
	mkdir -p dist/boot
	cp -rp boot dist
	cp src/bullseye.bin dist/boot/bullseye.bin
	grub-mkrescue -o dist/bullseye.iso dist

bochs: dist/bullseye.iso
	$(BOCHS) -q

qemu: dist/bullseye.iso
	$(QEMU) -cdrom dist/bullseye.iso

qemu-bin: src/bullseye.bin
	$(QEMU) -kernel src/bullseye.bin