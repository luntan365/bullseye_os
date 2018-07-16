all: libearly.a

libearly.a: early_main.o init_gdt.o
	$(AR) rcs libearly.a early_main.o init_gdt.o

early_main.o: early_main.asm
	$(ASM) $(ASMFLAGS) -o early_main.o early_main.asm

init_gdt.o: init_gdt.asm
	$(ASM) $(ASMFLAGS) -o init_gdt.o init_gdt.asm