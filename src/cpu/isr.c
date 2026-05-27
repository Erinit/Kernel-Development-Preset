#include "../include/idt.h"

void isr_handler() __attribute__((no_instrument_function));

// This is the function the assembly wrapper calls
void isr_handler() {
    // For now, keep it simple to verify it is called
    const char *msg = "Exception Caught!";
    char *vga = (char*)0xB8000;
    for(int i = 0; msg[i] != '\0'; i++) {
        vga[i*2] = msg[i];
        vga[i*2+1] = 0x4F; 
    }
    while(1); 
}