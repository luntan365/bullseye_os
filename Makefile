export ARCH=i686-elf
export AR=$(ARCH)-ar
export ASM=nasm
export ASMFLAGS=-felf32
export CC=$(ARCH)-gcc
export CFLAGS=-std=gnu99 -ffreestanding -O2
QEMU=qemu-system-i386

.PHONY: all clean

all: dist/bullseye.iso

clean:
	rm -rf dist
	find . -type f -name '*.o' -delete
	find . -type f -name '*.a' -delete
	find . -type f -name '*.bin' -delete
	find . -type f -name '*.iso' -delete

src/bullseye.bin:
	$(MAKE) -C src

dist/bullseye.iso: src/bullseye.bin
	grub-file --is-x86-multiboot src/bullseye.bin
	mkdir -p dist/boot
	cp -rp boot dist
	cp src/bullseye.bin dist/boot/bullseye.bin
	grub-mkrescue -o dist/bullseye.iso dist

qemu: dist/bullseye.iso
	$(QEMU) -cdrom dist/bullseye.iso