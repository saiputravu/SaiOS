#define BG 0x1f
#define VGA_ROWS 25 
#define VGA_COLS 80

short *vga_memory_buffer = (short *)0xb8000;
int x = 0;
int y = 0;

void putc(char c, char col) {
    short b = (col << 8) | c;
    if (c == 0x0a) y++ ;
    else *(vga_memory_buffer + (y * VGA_COLS) + x) = b;
    x++;
    if (x > VGA_COLS) {
        x = 0;
        y++;
    }
    if (y > VGA_ROWS) {
        x = 0; 
        y = 0;
    }
}

void puts(char *s) {
    char c;
    int i;
    while (c = s[i]) { 
        putc(c, BG);
        ++i;
    }
}

void kmain() {
    puts("Entered the kernel");
}