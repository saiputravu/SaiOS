OUTPUT_FORMAT(elf64-x86-64);

SECTIONS {
    /* BIOS loads bootloader at address 0000:0x7c00 */
    . = 0x7c00;

    .boot : { 
        *(.boot); 
        . = ALIGN(512); /* 0x200 = 512 = size of one sector */
    }
    
    .boot2 0x7e00 : {
        /* For where boot1 runs to */
        *(.boot2_entry); /* Has to be first */
        *(.boot2_text);
        *(.boot2_data);
        *(.boot2_rodata);
        . = ALIGN(512); /* To fill up the sector */
    }

    /* I want it to be 1M - need to find a fix around or load filesystem with bootloader or use pre-written bootloader */ 
    . = 0x9000;

    .text : {
        *(.text);
        . = ALIGN(0x200);
    }
    
    .data : {
        *(.data);
        . = ALIGN(0x200);
    }

    .rodata : {
        *(.rodata);
        . = ALIGN(0x200);
    }

    .bss : {
        *(COMMON);
        *(.bss);
        . = ALIGN(0x200);
    }

    /* Symbols for debugging in elf file with readelf -s */
    _boot_size = SIZEOF(.boot);     /* Verify: 0x200 */
    _boot2_size = SIZEOF(.boot2); 

    _text_size = SIZEOF(.text);
    _data_size = SIZEOF(.data);
    _rodata_size = SIZEOF(.rodata);
    _bss_size = SIZEOF(.bss);
}