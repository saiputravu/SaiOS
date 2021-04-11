;; Macro with 2 arguments
;;      Arg 1: Name of binary
;;      Arg 2: Filename of binary 
;; Includes any binary files and null terminates it
%macro inc_bin 2
    section .rodata
    global %1
%1: 
    incbin %2
    db 0
    %1_size: dq %1_size - %1
%endmacro

inc_bin ascii_image_1, "../misc/ascii_image.txt"