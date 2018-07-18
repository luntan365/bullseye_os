#.PHONY: all bootloader early link kernel

all: bullseye.bin

bootloader/libbootloader.a:
	$(MAKE) -C bootloader

early/libearly.a:
	$(MAKE) -C early

kernel/libkernel.a:
	$(MAKE) -C kernel

bullseye.bin: bootloader/libbootloader.a early/libearly.a kernel/libkernel.a
	$(CC) $(CFLAGS) -T linker.ld -o bullseye.bin -ffreestanding -O2 -nostdlib \
	bootloader/libbootloader.a early/libearly.a kernel/libkernel.a \
	-L$(shell pwd)/third_party/build_musl/lib \
	-lc -lm -lgcc