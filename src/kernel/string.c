#include "string.h"

char global_str_buffer[MAX_STRING] = {0};

size_t strlen(char *s, bool (*filter)(char) ) {
    size_t counter = 0;
    char c;
    while(c = s[counter]) {
        if (filter != nullptr){
            if (!filter(c))
                return 0; // If filter is false, filter for only certain letters
        }
        counter++;
    }
    return counter;
}

void memset(uchar *str, uchar c, size_t len) {
    for (int i = 0; i < len; ++i)
        str[i] = (uchar)c;
}

void memcpy(uchar *src, uchar *dst, size_t len) {
    for(int i = 0; i < len; ++i)
        dst[i] = src[i];
}


char *uitoa(uint num, int base, char (*base_character_selector)(uint_8)) {
    // Results stored in global buffer
    memset(global_str_buffer, 0, MAX_STRING);
    char *result = global_str_buffer;

    // Automatically select default base_selector 
    if (base_character_selector == nullptr)
        base_character_selector = base_selector;

    int times = 0;
    int n = num;
    while (n = (int)(n / base)) {
        times++;
    }

    for (int i = times; i >= 0; --i) {
        uint_8 c = num % base;
        result[i] = base_character_selector(c);
        num = (int)(num/base);
    }
    
    result[times+1] = '\0';
    return result;
}

char *itoa(int num, int base, char (*base_character_selector)(uint_8)) {
    // Results stored in global buffer
    memset(global_str_buffer, 0, MAX_STRING);
    char *result = global_str_buffer;

    // Automatically select the base to be 10
    if (base_character_selector == nullptr)
        base_character_selector = base_selector;

    int times = 0;
    int n = num;
    while (n = (int)(n / base)) {
        times++;
    }

    // Negative numbers need a '-' symbol
    bool neg = num < 0;
    if (neg) {
        num *= -1;
        result[0] = '-';
    }

    for (int i = times+neg; i >= neg; --i) {
        uint_8 c = num % base;
        result[i] = base_character_selector(c);
        num = (int)(num/base);
    }
    
    result[times+1+neg] = '\0';
    return result;
}

char *uint_to_hex(uint_64 num) {
    memset(global_str_buffer, 0, MAX_STRING);
    char *result = global_str_buffer;

    uint_64 *num_ptr = &num;
    uint_8* ptr;
    uint_8 temp, size;
    size = (sizeof(uint_64)) * 2 - 1;

    uint_8 i;
    for (i = 0; i<size; ++i) {
        ptr = ((uint_8*)num_ptr + i);
        temp = ((*ptr & 0xF0) >> 4);
        result[size - (i * 2 + 1)] = temp + (temp > 9 ? 0x37 : 0x30); 
        temp = (*ptr & 0x0F);
        result[size - (i * 2 + 0)] = temp + (temp > 9 ? 0x37 : 0x30); 
    }

    result[size + 1] = 0;
    return result;
}

uint_8 ctoi(char c) {
    if (is_num(c))
        return c-0x30;
    return 0xff;
}

int atoi(char *s) {
    size_t len = strlen(s, is_signed_num);
    int result = 0;
    for (int i = 1; i < len; ++i){ 
        result += power(10, len - 1 - i) * ctoi(s[i]);
    }

    // Check if first char is '-' or just regular number
    if (s[0] == '-')
        result *= -1;
    else 
        result += power(10, len - 1 - 0) * ctoi(s[0]);

    return 0;
}

bool is_printable(char c) {
    if ((c < 0x7f && c >= 0x20) || c == '\n' || c == '\t')
        return true;
    return false;
}

bool is_num(char c){
    if ((c <= 0x39 && c >= 0x30))
        return true;
    return false;
}

bool is_signed_num(char c){
    if (is_num(c) || c == '-')
        return true;
    return false;
}


char base_selector(uint_8 num) {
    switch (num){ 
        case 0:
            return '0';
        case 1:
            return '1';
        case 2:
            return '2';
        case 3:
            return '3';
        case 4:
            return '4';
        case 5:
            return '5';
        case 6:
            return '6';
        case 7:
            return '7';
        case 8:
            return '8';
        case 9:
            return '9';
        case 0xa:
            return 'a';
        case 0xb:
            return 'b';
        case 0xc:
            return 'c';
        case 0xd:
            return 'd';
        case 0xe:
            return 'e';
        case 0xf:
            return 'f';
        default:
            return ' ';
    }
}