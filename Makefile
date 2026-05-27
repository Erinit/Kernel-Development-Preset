CC=i686-elf-gcc
AS=i686-elf-as
CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra -Isrc/include
LDFLAGS=-T src/linker.ld -ffreestanding -O2 -nostdlib

OBJS = boot.o kernel.o cpu/gdt.o cpu/gdt_flush.o cpu/idt.o cpu/idt_load.o cpu/isr_asm.o cpu/isr.o
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

# IDT Compilation rules
cpu/idt.o: src/cpu/idt.c
	@mkdir -p cpu
	$(CC) -c src/cpu/idt.c -o cpu/idt.o $(CFLAGS)

cpu/idt_load.o: src/cpu/idt_load.s
	@mkdir -p cpu
	$(AS) src/cpu/idt_load.s -o cpu/idt_load.o

# Add a rule to compile the C isr file
cpu/isr.o: src/cpu/isr.c
	@mkdir -p cpu
	$(CC) -c src/cpu/isr.c -o cpu/isr.o $(CFLAGS)

# Ensure the assembly wrapper is named correctly (e.g., isr_asm.o)
cpu/isr_asm.o: src/cpu/isr.s
	@mkdir -p cpu
	$(AS) src/cpu/isr.s -o cpu/isr_asm.o

run: all
	qemu-system-i386 -kernel myos.bin -d int,cpu_reset -no-reboot

clean:
	rm -rf myos.bin *.o cpu/*.o