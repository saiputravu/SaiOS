section .boot
    bits 16 ; Start in real mode

    global start
    start:
        cli
        cld

        call clear_screen_real_mode
        mov byte [row], 0
        mov byte [col], 0
        call mov_cursor

        mov si, msg
        call print_string

        ; Read sectors from disk  - floppy disk

        ; ES:BX becomes 0x7e0:00 | Address 0x7e0 * 16 + 0
        ; Anything below 0x500 is reserved 
        mov ax, BOOT2_MEMORY_SEGMENT
        mov es, ax
        xor bx, bx

        mov al, 0x40 ; read n sectors 512 * 64 = 0x8000 so os.o cannot be larger (or it cannot access addresses larger than that) 
        mov cl, 2 ; sector 2 (kernel loaded here)
        mov ch, 0 ; cylinder/track 0 
        mov dh, 0 ; head 0 
        mov dl, 0 ; drive 0 (drive A:)

        mov ah, 0x02
        int 0x13

        ; Jump to Boot2
        jmp BOOT2_MEMORY_SEGMENT:0x00

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

    ; Padding and signature
    times 510-($-$$) db 0
    dw 0xaa55