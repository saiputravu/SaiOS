section .boot2_text
    bits 64

    extern dataseg
    extern kstart

    global start_long_mode
    start_long_mode:
        ; reload segments
        mov ax, dataseg 
        mov ds, ax 
        mov ss, ax 
        mov es, ax
        mov fs, ax 
        mov gs, ax 

        ; Message to show that we are in long mode now

        mov al, 0x2f
        call clear_screen_asm

        mov byte [0xb8100], 'E'
        mov byte [0xb8102], 'n'
        mov byte [0xb8104], 't'
        mov byte [0xb8106], 'e'
        mov byte [0xb8108], 'r'
        mov byte [0xb810a], 'e'
        mov byte [0xb810c], 'd'
        mov byte [0xb810e], ' '
        mov byte [0xb8110], 'L'
        mov byte [0xb8112], 'o'
        mov byte [0xb8114], 'n'
        mov byte [0xb8116], 'g'
        mov byte [0xb8118], 'M'
        mov byte [0xb811a], 'o'
        mov byte [0xb811c], 'd'
        mov byte [0xb811e], 'e'

        ; Jump to kernel start routine
        jmp kstart

    ; 64-bit implementation
    clear_screen_asm:
        ;; Arguments:
        ;;      Color | al : byte  
        mov rbx, 0x0020002000200020
        mov rcx, 4

        and rax, 0xff ; make sure rax is only one byte (otherwise why use this function bruh)
        shl rax, 8
    .load_quad:
        or rbx, rax
        shl rax, 16
        loop .load_quad

        mov edi, 0xb8000 ; Location (memory buffer)
        mov rax, rbx     ; value (spaces with color)
        mov ecx, 500     ; counter 
        rep stosq 
        ret



section .boot2_data 