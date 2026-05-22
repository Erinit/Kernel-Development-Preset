.set MAGIC,    0x1BADB002
.set FLAGS,    0
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

.section .text
.global _start
.extern kernel_main

_start:
    cli                 # Disable interrupts immediately
    mov $stack_top, %esp # Set up stack
    
    # Push multiboot info (optional but good practice)
    push %eax
    push %ebx
    
    call kernel_main

.Lhang:
    cli
    hlt
    jmp .Lhang
    