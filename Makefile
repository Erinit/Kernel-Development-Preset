all:
    docker run --rm -v "$(PWD):/osdev" -w /osdev randomdude/gcc-cross-x86_64-elf \
    x86_64-elf-gcc -m32 -T src/linker.ld -o myos.bin -ffreestanding -O2 -nostdlib \
    src/boot.s src/kernel.c -Wl,-m,elf_i386 -Wl,-z,max-page-size=4096