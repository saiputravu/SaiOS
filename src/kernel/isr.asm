section .text 

    %macro push_all_registers 0
        push rax
        push rbx
        push rcx
        push rdx
        push r8
        push r9
        push r10
        push r11
    %endmacro

    %macro pop_all_registers 0
        pop r11
        pop r10 
        pop r9
        pop r8
        pop rdx 
        pop rcx 
        pop rbx
        pop rax
    %endmacro

    extern isr1_handler
    global isr1
    isr1:  

        push_all_registers

        ; C defined handler
        call isr1_handler

        pop_all_registers 

        ; 64bit return
        iretq

    global load_idt
    load_idt:
        lidt [idt_descriptor] ; load idt
        sti ; enable interrupts 
        ret

section .dat
    extern _idt

    global idt_descriptor
    idt_descriptor:
        idt_size: dw (256 * 16) - 1
        idt_address: dq _idt
