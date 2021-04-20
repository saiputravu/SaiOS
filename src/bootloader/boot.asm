section .boot
    bits 16 ; Start in real mode

    global start
    start:
        cli
        cld
        jmp 0x0000:.clear_segment_registers ; Clear cs register

    .clear_segment_registers:
        xor ax, ax 
        mov ds, ax 
        mov es, ax 
        mov fs, ax 
        mov gs, ax

    .start_clean:
        mov byte [BOOT_DRIVE_NUMBER], dl

        call clear_screen_real_mode
        mov byte [row], 0
        mov byte [col], 0
        call mov_cursor

        mov si, msg
        call print_string

        ; Read sectors from disk  - Logical Block Addressing (treated as a hard disk drive)
        mov dl, byte [BOOT_DRIVE_NUMBER]
        mov si, dap

        mov ah, 0x42 
        int 0x13

        ; If there is a reading issue
        mov al, 'B'
        jc error

        ; Jump to Boot2
        jmp BOOT2_MEMORY_SEGMENT:0x00

        hlt
    
    error:
        mov bl, 0x5f
        mov cx, 1
        call print_char 
        hlt


    print_char:
        ; al: ASCII Character 
        ; bl: Colour
        ; cx: Number of times

        ; If char == 0x0a (\n)
        cmp al, 0x0a
        jne .normal_char

        inc byte [row]
        mov byte [col], 0
        call mov_cursor

        ret 

    .normal_char:
        mov bh, 0
        mov ah, 0x09
        int 0x10        ; Print coloured character

        ; Mov col along 1, if col == max_col size then col = 0, row += 1
        inc byte [col]
        call mov_cursor
        
        ret 

    print_string:
        ; Expected input from memory location
        ; in ds:si
        mov bl, 0x5f
        mov cx, 1

    .loop:
        mov al, [si]
        cmp al, 0
        jz .finish_loop    
        
        call print_char
        inc si 
        jmp .loop

    .finish_loop:
        ret

    clear_screen_real_mode:
        mov al, ' '
        mov bl, 0x50
        mov cx, 0xffff
        call print_char
        ret 

    mov_cursor:
        ; edit row
        ; edit col

        mov dh, [row]
        mov dl, [col]

        xor ax, ax 
        mov ah, 0x02
        int 0x10         ; set cursor position

        ret

    get_cursor:
        ; int returns:
        ;   ch,cl : start, end scan line
        ;   dh,dl : row, col
        ; function returns: None

        xor bx, bx
        mov ah, 0x03
        int 0x10
        
        mov [row], dh
        mov [col], dl

        ret 

    ; Variables
    col: db 0
    row: db 0
    cur_char: db 0
    BOOT2_MEMORY_SEGMENT equ 0x7c0 + 0x20

    msg: db "Sai's Bootloader!", 0x0a, 0

    dap: ; Data Address Packet
        db 0x10 ; size of DAP
        db 0x00 ; Unused
        
        dw 0x80 ; Number of sectors to read
        
        dw 0x0000 ; Offset  
        dw 0x07e0 ; Segment 

        dq 0x1 ; Start from 2nd sector
    
    BOOT_DRIVE_NUMBER: db 0

    ; Padding and signature
    times 510-($-$$) db 0
    dw 0xaa55