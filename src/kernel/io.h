#pragma once

#include "types.h"

/* =============== I/O Ports =============== */

// Programmable Interrupt Controller IO Ports
// https://wiki.osdev.org/PIC#Initialisation

#define MASTER_PIC_COMMAND  0x20
#define MASTER_PIC_DATA     0x21 // MASTER_PIC_COMMAND + 1

#define SLAVE_PIC_COMMAND   0xa0
#define SLAVE_PIC_DATA      0xa1 // SLAVE_PIC_COMMAND + 1 

/*
    Initialise command 0x11 for the 2 PICs makes them wait for 4 total (3 extra) "initialise command words" (ICW) on data ports

    ICW1 : First word  | (I think) flags
    ICW2 : Second word | vector offset for interrupt
    ICW3 : Third word  | master/slave wiring
    ICW4 : Fourth word | environment information 

    Further reading:
        - Pages 10,11 | https://pdos.csail.mit.edu/6.828/2018/readings/hardware/8259A.pdf
*/
#define ICW1_ICW4       0x01		// ICW4 (not) needed
#define ICW1_SINGLE     0x02		// Single (cascade) mode
#define ICW1_INTERVAL4  0x04		// Call address interval 4 (8)
#define ICW1_LEVEL      0x08		// Level triggered (edge) mode
#define ICW1_INIT       0x10		// Initialization - required!

#define ICW1_FINISHED_SERVICING 0x20 // CPU tells PIC to resume sending interrupts 
 
#define ICW4_8086       0x01		// 8086/88 (MCS-80/85) mode
#define ICW4_AUTO       0x02		// Auto (normal) EOI
#define ICW4_BUF_SLAVE  0x08		// Buffered mode/slave
#define ICW4_BUF_MASTER	0x0C		// Buffered mode/master
#define ICW4_SFNM       0x10		// Special fully nested (not)


/* =============== I/O Functions =============== */

void outb(ushort port, uchar val);
uchar inb(ushort port);

/*
    Re-initialise Programmable Interrupt Controllers to give specific vector offsets (instead of 0x8, 0x70 etc)
    offset1 : Master PIC interrupt vector offsets beginning at offset1...offset1 + 7
    offset2 : Slave PIC interrupt vector offsets beginning at offset2...offset2 + 7

    Note: on some chipsets you may need an I/O Wait between each outb(); as the information might not be processed as quickly

   For more information check out
    * https://wiki.osdev.org/PIC#Real_Mode
    * https://wiki.osdev.org/PIC#Initialisation
*/
void remap_pic(uint offset1, uint offset2);