#pragma once

#include "io.h"
#include "types.h"

/* ================= VGA DEFINITIONS ================= */
#define VGA_HEIGHT 25
#define VGA_WIDTH 80
#define TAB_SPACE 4

/* ================= FOREGROUND VGA COLORS ================= */
#define FOREGROUND_BLACK        0x00
#define FOREGROUND_BLUE         0x01
#define FOREGROUND_GREEN        0x02
#define FOREGROUND_CYAN         0x03
#define FOREGROUND_RED          0x04
#define FOREGROUND_MAGENTA      0x05
#define FOREGROUND_BROWN        0x06
#define FOREGROUND_LIGHTGREY    0x07
#define FOREGROUND_DARKGREY     0x08
#define FOREGROUND_LIGHTBLUE    0x09
#define FOREGROUND_LIGHTGREEN   0x0a
#define FOREGROUND_LIGHTCYAN    0x0b
#define FOREGROUND_LIGHTRED     0x0c
#define FOREGROUND_LIGHTMAGENTA 0x0d
#define FOREGROUND_YELLOW       0x0e
#define FOREGROUND_WHITE        0x0f

/* ================= BACKGROUND VGA COLORS ================= */
#define BACKGROUND_BLACK        0x00
#define BACKGROUND_BLUE         0x10
#define BACKGROUND_GREEN        0x20
#define BACKGROUND_CYAN         0x30
#define BACKGROUND_RED          0x40
#define BACKGROUND_MAGENTA      0x50
#define BACKGROUND_BROWN        0x60
#define BACKGROUND_LIGHTGREY    0x70
#define BACKGROUND_DARKGREY     0x80
#define BACKGROUND_LIGHTBLUE    0x90
#define BACKGROUND_LIGHTGREEN   0xa0
#define BACKGROUND_LIGHTCYAN    0xb0
#define BACKGROUND_LIGHTRED     0xc0
#define BACKGROUND_LIGHTMAGENTA 0xd0
#define BACKGROUND_YELLOW       0xe0
#define BACKGROUND_WHITE        0xf0

void vga_putc(char c, uchar col);
void vga_puts(char *c, uchar col);
void vga_clear_screen(uchar col);

void vga_update_cursor(uint arg_x, uint arg_y);
uint vga_from_coords(uint arg_x, uint arg_y);