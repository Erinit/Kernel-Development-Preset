#include "../include/io.h"
#include <stdint.h>

volatile uint16_t* vga = (volatile uint16_t*)0xB8000;

// Cursor tracking variables
static int cursor_x = 0;
static int cursor_y = 0;

// Basic scancode mapping for English QWERTY
static const char kbd_map[] = {
    0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b', '\t',
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n', 0,
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\',
    'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '
};

// Helper to move the blinking VGA hardware cursor
void update_cursor(int x, int y) {
    // The screen is 80 characters wide. Calculate linear memory offset.
    uint16_t pos = y * 80 + x;
    
    // VGA port 0x3D4 is the command port, 0x3D5 is the data port.
    // Command 0x0F is for the Low byte of the cursor position
    outb(0x3D4, 0x0F);
    outb(0x3D5, (uint8_t) (pos & 0xFF));
    
    // Command 0x0E is for the High byte of the cursor position
    outb(0x3D4, 0x0E);
    outb(0x3D5, (uint8_t) ((pos >> 8) & 0xFF));
}

// Replace your current terminal_putchar with this upgraded one

void terminal_putchar(char c) {
    if (c == '\b') {
        // --- BACKSPACE LOGIC ---
        if (cursor_x > 0) {
            cursor_x--;
        } else if (cursor_y > 0) {
            // If we are at the left edge, wrap back to the end of the previous line
            cursor_y--;
            cursor_x = 79; 
        } else {
            // We are at the very top-left (0,0), nowhere to backspace to!
            return; 
        }
        
        // Calculate the memory index of our newly moved cursor
        int index = (cursor_y * 80) + cursor_x;
        
        // Overwrite whatever was there with a blank space (with standard colors)
        vga[index] = 0x0F00 | ' ';
        
        // IMPORTANT: We return here so we don't accidentally advance 
        // cursor_x at the bottom of the function.
        return; 
        
    } else if (c == '\n') {
        // --- NEWLINE LOGIC ---
        cursor_x = 0;
        cursor_y++;
    } else {
        // --- NORMAL CHARACTER LOGIC ---
        int index = (cursor_y * 80) + cursor_x;
        vga[index] = 0x0F00 | c; 
        cursor_x++;
    }

    // Line wrap if we hit the right edge
    if (cursor_x >= 80) {
        cursor_x = 0;
        cursor_y++;
    }

    // Screen wrap if we hit the bottom
    if (cursor_y >= 25) {
        cursor_y = 0; 
    }
    update_cursor(cursor_x, cursor_y);
}

void keyboard_handler() {
    uint8_t scancode = inb(0x60);
    
    // Check if bit 7 is set (0x80) - this is a key release
    if (!(scancode & 0x80)) {
        // This is a press event
        if (scancode < sizeof(kbd_map)) {
            char c = kbd_map[scancode];
            if (c != 0) {
                terminal_putchar(c);
            }
        }
    }
    
    // Acknowledge the interrupt to the PIC (Master PIC)
    outb(0x20, 0x20); 
}

void isr_handler() {
    const char *msg = "Exception Caught!";
    char *vga_ptr = (char*)0xB8000;
    
    // Print in red (0x4F) at the very top of the screen
    for(int i = 0; msg[i] != '\0'; i++) {
        vga_ptr[i*2] = msg[i];
        vga_ptr[i*2+1] = 0x4F;
    }
    
    // Halt the CPU completely on exception
    while(1) {
        asm volatile ("cli; hlt");
    }
}