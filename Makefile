CC=i686-elf-gcc
AS=i686-elf-as
CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra -Isrc/include
LDFLAGS=-T src/linker.ld -ffreestanding -O2 -nostdlib

OBJS = boot.o kernel.o cpu/gdt.o cpu/gdt_flush.o

all: myos.bin

myos.bin: $(OBJS)
	$(CC) $(LDFLAGS) -o myos.bin $(OBJS) -lgcc

# Compilation rules
boot.o: src/boot.s
	$(AS) src/boot.s -o boot.o

kernel.o: src/kernel.c
	$(CC) -c src/kernel.c -o kernel.o $(CFLAGS)

cpu/gdt.o: src/cpu/gdt.c
	@mkdir -p cpu
	$(CC) -c src/cpu/gdt.c -o cpu/gdt.o $(CFLAGS)

cpu/gdt_flush.o: src/cpu/gdt_flush.s
	@mkdir -p cpu
	$(AS) src/cpu/gdt_flush.s -o cpu/gdt_flush.o

# The missing target
run: all
	qemu-system-i386 -kernel myos.bin -d int,cpu_reset -no-reboot

clean:
	rm -rf myos.bin *.o cpu/*.o