section .boot2_text
    bits 32

    extern dataseg
    extern codeseg
    extern print_prot_message
    extern start_long_mode

    extern gdt_codedesc
    extern gdt_datadesc

    global start_protected_mode
    start_protected_mode:
        ; Update segment registers
        mov ax, dataseg 
        mov ds, ax 
        mov ss, ax 
        mov es, ax 
        mov fs, ax 
        mov gs, ax 

        ; Print message
        mov byte [0xb8100], 'E'
        mov byte [0xb8102], 'n'
        mov byte [0xb8104], 't'
        mov byte [0xb8106], 'e'
        mov byte [0xb8108], 'r'
        mov byte [0xb810a], 'e'
        mov byte [0xb810c], 'd'
        mov byte [0xb810e], ' '
        mov byte [0xb8110], 'P'
        mov byte [0xb8112], 'r'
        mov byte [0xb8114], 'o'
        mov byte [0xb8116], 't'
        mov byte [0xb8118], 'M'
        mov byte [0xb811a], 'o'
        mov byte [0xb811c], 'd'
        mov byte [0xb811e], 'e'

        ; Set 64 bit mode (long mode)
        ; 1. Detect CPUID allows x86_64 
        ; 2. Disable paging
        ; 3. Enable PAE in CR4
        ; 4. Load CR3 with Page Table Register value
        ; 5. Enable long mode
        ; 6. Enable paging

        ;1. 
        ; Check for CPUID opcode 
        call check_cpuid_available
        cmp eax, 0
        mov al, 'C'
        je error ; CPU does not support CPUID opcode

        ; Check for 64bit CPU
        call check_cpuid_long_mode
        cmp eax, 0
        mov al, 'L'
        je error ; CPU is not 64bit CPU
        
        ;2. 
        call disable_paging

        ;3.         
        call enable_pae

        ;4. Setup identity (1:1) paging
        call setup_identity_paging

        ;5. Enable long mode using MSR 
        call enable_msr_long_mode

        ;6. 
        call enable_paging

        ; First update GDT entries for 64 bits
        call update_gdt

        ; Move to 64 bit operations now 
        jmp codeseg:start_long_mode

    error:
        mov byte [0xb8200], 'E'
        mov byte [0xb8202], 'r'
        mov byte [0xb8204], 'r'
        mov byte [0xb8206], 'o'
        mov byte [0xb8208], 'r'
        mov byte [0xb820a], ' '
        mov byte [0xb820c], al
        hlt

    update_gdt:
        mov byte [gdt_codedesc + 6], 10101111b  ; GDT Code descriptor Flags update
                                                ; Changes:
                                                ;   * L = 1
                                                ;   * Sz = 0
        mov byte [gdt_datadesc + 6], 10101111b ; GDT Data descriptor Flags update
        ret 

    disable_paging:
        ; Note bits start counting from 0 

        mov eax, cr0 
        mov ebx, 1 << 31 ; unset bit 31
        not ebx          
        and eax, ebx     ; Disable only bit 31
        mov cr0, eax
        ret
    
    enable_paging:

        mov eax, cr0
        or eax, 1 << 31 ; set bit 31 (paging enabled bit)
        mov cr0, eax
        ret

    enable_pae:
        mov eax, cr4
        or eax, 1 << 5 ; set bit 5 (PAE enabled bit)
        mov cr4, eax 
        ret

    enable_msr_long_mode:
        mov ecx, 0xc0000080
        rdmsr ; eax = msr
        or eax, 1 << 8 ; set bit 8 of msr (long mode enabled bit)
        wrmsr ; msr = eax ^ (1<<8)
        
        ; Check if it has actually been written 
        rdmsr
        test eax, 1 << 8
        mov al, 'M'
        jz error

        ret

    setup_identity_paging:
        mov edi, pagetable_entry
        mov cr3, edi

        ; 0x1000 is 4KiB
        ; Format : 4KB aligned addr (20 bits) | Avail (2 bits) | Flags (10bits)
        ; Flags  : G|S|0|A|D|W|U|R|P
        ; Flags  : Ignored|Page Size (0 or 4KB)|Accessed|Cache Disabled|Write Through|User|Read/Write|Present

        ; Level 4 @ 0x1003 | [0x2003] 1 Entry  
        ;   + 4KiB | Level 3 @ 0x2003 | [0x3003] 1 Entry
        ;       + 4KiB | Level 2 @ 0x3003 | [0x4003] 1 Entry 
        ;           + 4KiB | Level 1 @ 0x4003 | [...] 512 Entries (looped)

        mov dword [edi], 0x2003 
        add edi, 0x1000         ; +4KiB to next table (level 3)
        mov dword [edi], 0x3003  
        add edi, 0x1000         ; +4KiB to next table (level 2)
        mov dword [edi], 0x4003  
        add edi, 0x1000         ; +4KiB to next table (level 1)

        mov ebx, 0x00000003 ; Actual entry
        mov ecx, 512 ; num entries (loop counter)

    .set_entry:
        mov dword [edi], ebx 
        add ebx, 0x1000 ; Each entry points to 4KiB chunks in linear memory
        add edi, 8 ; Each entry size is 8 bits
        loop .set_entry ; ecx is counter

        ret 

    check_cpuid_available:
        ;; No Function arguments  
        ;; Returns eax = 0 | 1 depending on result

        ; Check the eflags register ID bit 21
        ; If you flip and it doesn't change you cant use 
        pushfd 
        pop eax ; eax = eflags 
        mov ecx, eax ; ecx = eax = eflags 
        xor eax, 1 << 21 ; eax ^ (1<<21)
        push eax 
        popfd ; eflags = eax ^ (1<<21)

        ; Check ecx = eflags 
        pushfd 
        pop eax 
        cmp eax, ecx 
        jz .cpuid_not_available 
        mov eax, 1
        jmp .finish 
    .cpuid_not_available:
        mov eax, 0
    .finish:
        ret

    check_cpuid_long_mode:
        mov eax, 0x80000001
        cpuid 
        test edx, 1 << 29 ; Check if bit 29 is flipped
        jz .long_mode_support_disabled
        mov eax, 1
        jmp .finish
    .long_mode_support_disabled:
        mov eax, 0
    .finish:    
        ret

    enable_cpuid_long_mode:
        call check_cpuid_available
        cmp eax, 0
        je .finish 
        ; Enable long mode 
    .finish:
        ret


section .boot2_data
    pagetable_entry equ 0x1000 
