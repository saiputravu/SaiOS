#include "vga.h"

ushort *vga_memory_buffer = (ushort *)0xb8000;
uint x, y;

void vga_putc(char c, uchar col) {
    ushort b = (col << 8) | c;

    // Special characters
    switch (c) {
        case '\n':
            x = 0;
            y++;
            break;
        case '\t':
            x += TAB_SPACE;
            break;
        default:
            vga_memory_buffer[y * VGA_WIDTH + x] = b;
            x++;
            break;
    }

    // Wrap around
    if (x >= VGA_WIDTH) {
        x = 0;
        y++;
    }
    if (y >= VGA_HEIGHT) {
        y = 0;
    }

    // Cursor update
    vga_update_cursor(x, y);
}

void vga_puts(char *s, uchar col) {
    char c;
    int i;
    while (c = s[i]) { 
        vga_putc(c, col);
        ++i;
    }
}

void vga_clear_screen(uchar col) {
    vga_update_cursor(0, 0);
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; ++i)
        vga_putc(' ', col);
}

void vga_update_cursor(uint arg_x, uint arg_y) {
    x = arg_x;
    y = arg_y;
    uint pos = vga_from_coords(arg_x, arg_y);
    // VGA register, 0x0f index to say update cursor
    // Update 0x00ff then 0xff00
    outb(0x3d4, 0x0f);
    outb(0x3d5, (uchar)(pos & 0xff));
    outb(0x3d4, 0x0e);
    outb(0x3d5, (uchar)((pos >> 8) & 0xff));
}

uint vga_from_coords(uint arg_x, uint arg_y) {
    return arg_y * VGA_WIDTH + arg_x;
}
