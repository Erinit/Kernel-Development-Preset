CC = i686-elf-gcc
AS = i686-elf-as
CFLAGS = -m32 -c -std=gnu99 -ffreestanding -O2 -Wall -Wextra
# FIXED: Points the linker script target directly inside the src/ folder
LDFLAGS = -m32 -T src/linker.ld -ffreestanding -O2 -nostdlib -Wl,-m,elf_i386 -Wl,-z,max-page-size=4096

all: myos.bin

boot.o: src/boot.s
	$(AS) --32 src/boot.s -o boot.o

kernel.o: src/kernel.c
	$(CC) $(CFLAGS) src/kernel.c -o kernel.o

# FIXED: Monitors src/linker.ld so make rebuilds if you change it
myos.bin: boot.o kernel.o src/linker.ld
	$(CC) $(LDFLAGS) -o myos.bin boot.o kernel.o

run: myos.bin
	qemu-system-i386 -kernel myos.bin

clean:
	rm -f *.o myos.bin