all: libkernel.a

libkernel.a: kernel.o inline.o isr_handler.o
	$(AR) rcs libkernel.a kernel.o inline.o isr_handler.o

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c -o kernel.o kernel.c

isr_handler.o: isr_handler.c
	$(CC) $(CFLAGS) -c -o isr_handler.o isr_handler.c