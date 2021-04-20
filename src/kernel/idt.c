#include "idt.h"

// IDT Table (array) - Linked so must be called _idt
extern struct IDTDescr_64 _idt[256];

void init_idt() {
    /*
        Steps to setting up an IDT
        https://wiki.osdev.org/Interrupts (Section "So how do I program this stuff?")

        1. Make space for IDT 
            -> Done, in linker and _idt[256]

        2. Tell CPU where that space is
            -> load_idt function | lidt

        3. Tell the 8259 PIC (Programmable Interrupt Controller) that we don't want to use BIOS default Interrupt Vector Table
            -> https://wiki.osdev.org/PIC#Disabling

        4. Write ISRs for IRQs and exceptions
            -> irs1 etc.

        5. Put addresses of ISRs in correct descriptors (in the IDT)

        6. Enable all supported interrupts in the IRQ mask (of the PIC)
            -> https://wiki.osdev.org/PIC#How_does_the_8259_PIC_chip_work.3F
            -> https://wiki.osdev.org/PIC#Programming_with_the_8259_PIC
            -> Its sort of like SPI, where there is a master and slave 
    */

    // 4.
    // Set all entries to not present
    add_idt_entry(1, &isr1, 0x08, 0b10001110);

    // Remap the vectors so that you know what isr1 means
    // Remapped Interrupt Vectors {MASTER}[0..7] | {SLAVE}[8..15] 
    remap_pic(0, 8);

    // 3. 
    outb(MASTER_PIC_DATA, 0xfd);
    outb(SLAVE_PIC_DATA, 0xff);     

    // 2.
    load_idt();
}

void add_idt_entry(uint_64 indx, uint_64 *offset, uint_16 selector, uint_8 type_attr) {
    if (indx < 0 || indx >= 256)
        return;
    _idt[indx].offset_1 = (uint_16)( ((uint_64)offset) & 0xffff );
    _idt[indx].offset_2 = (uint_16)( (((uint_64)offset) >> 16) & 0xffff);
    _idt[indx].offset_3 = (uint_32)( (((uint_64)offset) >> (16 + 16)) & 0xffffffff);
    _idt[indx].selector = selector; // Codeseg offset into GDT
    _idt[indx].type_attr = type_attr; // Not Present, PrivL 0, 32bit interrupt gate
    _idt[indx].ist = 0;
    _idt[indx].reserved = 0;
}

void finished_servicing_interrupt() {
    /*
        Interrupt Priority (MOST to LEAST): 
            0, 1, 2, 8, 9, 10, 11, 12, 13, 14, 15, 3, 4, 5, 6, 7

        CPU needs to tell the PIC to resume sending interrupts 
        Think of both MASTER and SLAVE PIC as their separate interrupt PICS
            - but if slave wants to talk to CPU to tell it an interrupt occured, SLAVE out goes to MASTER input #2 which outputs to CPU

        Further Reading: 
            - https://wiki.osdev.org/Interrupts#From_the_PIC.27s_perspective
    */

    outb(MASTER_PIC_COMMAND, ICW1_FINISHED_SERVICING);
    outb(SLAVE_PIC_COMMAND, ICW1_FINISHED_SERVICING);
}

void isr1_handler() {

    extern uchar colour;
    uint_8 keyboard_char = inb(0x60); 

    if (pressed_key(keyboard_char) != 0)
        vga_putc(pressed_key(keyboard_char), colour);

    finished_servicing_interrupt();
}