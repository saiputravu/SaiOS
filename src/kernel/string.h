#pragma once 

#include "types.h"
#include "math.h"

// Just for simplicity where you need small strings but an upper limit
#define MAX_STRING 512

// Gets the length of an ascii zero'd character array
// Also takes an optional parameter to filter on loop
size_t strlen(char *s, bool (*filter)(char) );

// Returns a signed integer from an ascii zero'd character array
int atoi(char *str);

// Returns an ascii zero'd string (uses the global string buffer)
// Takes in a base_character_selector function which should return a character, given a number 0 to (base-1)
// Leave base_character_selector to be nullptr to select default base_selector
char *itoa(int num, int base, char (*base_character_selector)(uint_8));     // Signed - Has an issue needs to be fixed 
char *uitoa(uint num, int base, char (*base_character_selector)(uint_8));   // Unsigned

// Returns a hex string
char *uint_to_hex(uint_64 num);

// Built-in base selector
// Supports up to hex 0xf
char base_selector(uint_8 num);

// Returns a single digit integer, if failed returns 0xff
uint_8 ctoi(char c);

// Standard memory functions (BOF warning, I haven't done any safety)
void memset(uchar *str, uchar c, size_t len);
void memcpy(uchar *src, uchar *dst, size_t len);

/* ================== FILTERS =================== */
// Returns if a character is an printable ascii character (0x20 <= x <= 0x7e or 0x0a, 0x09) 
bool is_printable(char c);

// Returns if a character is 0-9
bool is_num(char c);

// Returns if a character is_num or '-'
bool is_signed_num(char c);