#include "vga.h"
#include "string.h"

extern const char ascii_image_1[];

void kmain() {
    vga_clear_screen(BACKGROUND_WHITE);
    vga_puts((char *)ascii_image_1, BACKGROUND_WHITE | FOREGROUND_RED);
}