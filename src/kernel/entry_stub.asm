section .text

    extern kmain

    global kstart 
    kstart: 
        call kmain 
        
        jmp $

section .data

section .rodata 
    msg: db "This is a kernel message", 0