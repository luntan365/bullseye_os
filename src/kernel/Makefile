all: libkernel.a

libkernel.a: kernel.o
	$(AR) rcs libkernel.a kernel.o

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c -o kernel.o kernel.c