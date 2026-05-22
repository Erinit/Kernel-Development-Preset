#include <stdint.h>

void kernel_main(void) {
    uint16_t* vga = (uint16_t*) 0xB8000;
    
    // Write just one character to test the screen works
    vga[0] = 0x0F41; // 'A' in white on black

    for (;;) {
        asm volatile ("hlt");
    }
}
