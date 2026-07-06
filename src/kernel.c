#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// 1. Core VGA configuration values
#define VGA_WIDTH   80
#define VGA_HEIGHT  25
#define VGA_MEMORY  0xB8000 

void kernel_main(void) 
{
    // 2. Establish a raw pointer directly to the VGA text mode memory address
    uint16_t* terminal_buffer = (uint16_t*)VGA_MEMORY;

    // 3. Create a static text color attribute (White text [15] on a Blue background [1])
    // The background color is shifted left by 4 bits because it uses the upper nibble of the byte
    uint8_t color_attribute = 15 | (1 << 4);

    // 4. Clear the screen by writing blank spaces (' ') to every character grid coordinate
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            // A VGA character entry is 16-bits: character byte in lower 8 bits, color byte in upper 8 bits
            terminal_buffer[index] = (uint16_t)' ' | (uint16_t)color_attribute << 8;
        }
    }

    // 5. Define our output string
    const char* message = "Hello World!!!";

    // 6. Output our string directly to the very first row of the screen
    for (size_t i = 0; message[i] != '\0'; i++) {
        terminal_buffer[i] = (uint16_t)message[i] | (uint16_t)color_attribute << 8;
    }

    // 7. Freeze the execution thread so the CPU sits in an idle loop
    for(;;) {
        __asm__ volatile ("hlt");
    }
}
