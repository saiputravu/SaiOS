; .text 
section .boot2_entry
    bits 16

    extern start_protected_mode

    global boot2_start
    boot2_start:
        ; stack pointer
        mov bp, BOOT2_MEMORY_SPACE
        mov sp, bp

        call print_kernel_message
        
        ; Set 32 bit mode (protected mode)
        jmp enable_protected_mode

section .boot2_text
    enable_protected_mode:
        ; 1. Clear Registers
        ; 2. Enable A20 Bus Line
        ; 3. Setup GDT 
        ; 4. Set CR0 Register lowest bit to 1

        ;1.
        cli

        ;2.
        call enable_a20

        ;3.
        lgdt [gdt_descriptor]

        ;4.
        mov eax, cr0
        or al, 1
        mov cr0, eax

        ; Setting cs reg to codeseg (in real mode behaviour is different)
        jmp codeseg:start_protected_mode

    enable_a20:
        in al, 0x92
        test al, 0x02
        jnz .enabled_already
        or al, 0x02
        and al, 0xfe
        out 0x92, al 
    .enabled_already:
        ret

    print_kernel_message:
        mov si, kmsg
    .loop:
        mov al, [si]
        mov ah, 0x0e
        int 0x10

        inc si

        cmp byte [si], 0
        jne .loop

        ret

;.data
section .boot2_data
    ; gdt protected mode

    global gdt_codedesc
    global gdt_datadesc
    gdt_start:
        gdt_nulldesc:
            dd 0 
            dd 0 

        gdt_codedesc:   ; base: 0x0, limit: 0xffff ffff, 
                        ; Access: Pr=1, Privl=00, S=1, Ex=1, DC=0, RW=1, Ac=0
                        ; Flags: Gr=1, Sz=1

            dw 0xffff ; LIMIT (lower)
            dw 0x0000 ; BASE (lower)
            db 0x00   ; BASE (middle)
            db 10011010b ; ACCESS
            db 11001111b ; Flags | LIMIT (upper) 
            db 0x00   ; BASE (upper)

        gdt_datadesc:   ; base: 0x0, limit: 0xffff ffff, 
                        ; Access: Pr=1, Privl=00, S=1, Ex=0, DC=0, RW=1, Ac=0
                        ; Flags: Gr=1, Sz=1

            dw 0xffff ; LIMIT (lower)
            dw 0x0000 ; BASE (lower)
            db 0x00   ; BASE (middle)
            db 10010010b ; ACCESS
            db 11001111b ; Flags | LIMIT (upper) 
            db 0x00   ; BASE (upper)

        ;gdt_tssdesc:
    gdt_end:

    gdt_descriptor:
        gdt_size: dw (gdt_start - gdt_end - 1)
        gdt_address: dq gdt_start


    global codeseg 
    global dataseg
    codeseg equ gdt_codedesc - gdt_start 
    dataseg equ gdt_datadesc - gdt_start
    BOOT2_MEMORY_SPACE equ 0x7c00 + 0x200

;.rodata
section .boot2_rodata
    kmsg: db "This is the second bootloader" , 0xa, 0