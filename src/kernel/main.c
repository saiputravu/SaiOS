#include "vga.h"
#include "string.h"
#include "idt.h"

extern const char ascii_image_1[];

uchar colour = BACKGROUND_WHITE | FOREGROUND_RED; 

void kmain() {
    /* Kernel setup */
    init_idt();

    vga_clear_screen(colour);
}