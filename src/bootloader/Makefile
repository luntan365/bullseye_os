all: libbootloader.a

libbootloader.a: bootloader.o
	$(AR) rcs libbootloader.a bootloader.o

bootloader.o: $(ARCH).asm
	$(ASM) $(ASMFLAGS) -o bootloader.o $(ARCH).asm