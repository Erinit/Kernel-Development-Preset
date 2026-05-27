.global isr_common_stub
.extern isr_handler

isr_common_stub:
    pusha           # Save all general-purpose registers
    push %ds        # Save data segment
    
    mov $0x10, %ax  # Load kernel data segment
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    
    call isr_handler # Call C function
    
    pop %ds         # Restore data segment
    popa            # Restore general-purpose registers
    add $8, %esp    # Clean stack
    iret            # Return from interrupt