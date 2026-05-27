#include "../include/idt.h"

struct idt_entry idt[256];
struct idt_ptr idtp;

extern void idt_load(); // Defined in assembly

void idt_set_gate(unsigned char num, unsigned long base, unsigned short sel, unsigned char flags) {
    idt[num].base_low = (base & 0xFFFF);
    idt[num].base_high = (base >> 16) & 0xFFFF;
    idt[num].selector = sel;
    idt[num].always0 = 0;
    idt[num].flags = flags;
}

extern void isr_common_stub();

void idt_install() {
    // 0x08 is the code segment, 0x8E is the gate attribute
    idt_set_gate(0, (unsigned long)isr_common_stub, 0x08, 0x8E); 
    
    idtp.limit = (sizeof(struct idt_entry) * 256) - 1;
    idtp.base = (unsigned int)&idt;
    idt_load();
}