#pragma once 

#include "types.h"
#include "io.h"
#include "vga.h"
#include "string.h"
#include "keyboard.h"

/* 
    General information:

    * IDT iret / iretq:
        INT 50 = 50*8 into the IDT 
        If the interrupt uses a 16bit selector and must perform a 32bit/64bit return
        So do iret (32bit return) or iretq (64bit return) depending on use cases.
    

    * ISRs:
    - https://wiki.osdev.org/Interrupt_Service_Routines
*/


extern void load_idt();
void init_idt();
void add_idt_entry(uint_64 indx, uint_64 *offset, uint_16 selector, uint_8 type_attr);

/* ================ Interrupt Service Routines ================ */

// Keyboard handler
extern uint_64 isr1;
extern const char keyboard_table[];
void isr1_handler();

/* ================ STRUCTURES ================ */

struct IDTDescr_64 {
    uint_16 offset_1;   // Offset low (total 64 bits)
    uint_16 selector;   // Segment selector (must point to vaild point in GDT)
    uint_8 ist;         // Bits 0-2 hold Interrupt Stack Table offset (in TSS), rest 0 (Usually completely zero'd)
    uint_8 type_attr;   // Type: bits 40..43; Attribute: bits 44..47
                        //  7                               0
                        //  +---+---+---+---+---+---+---+---+
                        //  | P |  DPL  | Z |    GateType   |
                        //  +---+---+---+---+---+---+---+---+

                        // Possible Gate Types:
                        //  * 0b0101 0x5 | 32bit task gate
                        //  * 0b0110 0x6 | 16bit interrupt gate
                        //  * 0b0111 0x7 | 16bit trap gate
                        //  * 0b1110 0xe | 32bit interrupt gate
                        //  * 0b1111 0xf | 32bit trap gate

                        // Attributes:
                        //  * bit 44 :      S   | Storage Segment: Set 0 for interrupt and trap gates
                        //  * bits 45,46 :  DPL | Descriptor Priv Level: Gets call protection, min descriptor privl. Protection from hardware and CPU int from userspace
                        //  * bit 47 :      P   | Present: Set 0 for unused interrupts

    uint_16 offset_2;   // Offset mid
    uint_32 offset_3;   // Offset high
    uint_32 reserved;   // Reserved bits
};