#include "io.h"

/* I/O Ports */
void outb(unsigned short port, unsigned char val) {
    __asm__ volatile ( 
        "outb %0, %1" 
        : 
        : "a"(val), "Nd"(port)
        );
}

unsigned char inb(unsigned short port) {
    unsigned char result;
    __asm__ volatile (
        "inb %1, %0"
        : "=a"(result)
        : "Nd"(port)
    );
    return result;
}

void remap_pic(uint offset1, uint offset2) {
    uchar a1, a2;

    // Save interrupt masks
    a1 = inb(MASTER_PIC_DATA);
    a2 = inb(SLAVE_PIC_DATA);

    // Start initialise sequence (cascade mode)
    // Look at the definition in io.h for more information
    outb(MASTER_PIC_COMMAND, ICW1_INIT | ICW1_ICW4);    // Use ICW4 input
    outb(SLAVE_PIC_COMMAND, ICW1_INIT | ICW1_ICW4);
    
    // Give ICW2 (vector offsets - mentioned in prototype in io.h)
    outb(MASTER_PIC_DATA, offset1);
    outb(SLAVE_PIC_DATA, offset2);

    // Give ICW3 (Master / Slave wiring)
    // Tell master: slave at IRQ2 (0000 0100)
    // Tell slave : cascade identity of itself (0000 0010)
    outb(MASTER_PIC_DATA, 0b0100);
    outb(SLAVE_PIC_DATA, 0b0010);

    // Give ICW4 (Environment information)
    outb(MASTER_PIC_DATA, ICW4_8086);
    outb(SLAVE_PIC_DATA, ICW4_8086);


    // Restore saved masks
    outb(MASTER_PIC_DATA, a1);
    outb(SLAVE_PIC_DATA, a2);
}