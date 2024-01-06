; Streams.
%define stdout 0
%define stdin  1
%define stderr 2

; System calls.
%define SYS_exit 1
%define SYS_write 4

; @TODO: add new stuff here

section .text
align 4 ; @TODO: I don't know what this is for yet, investigate.
access.kernel:
        int 80h
        ret

; ------
; Macros
; ------

; Macro that accepts a single argument, which is the syscall number code.
%macro system 1
       mov eax, %1
       call access.kernel
%endmacro

; Exit
%macro sys.exit 0
       system SYS_exit
%endmacro

; Read
%macro sys.write 0
       system SYS_write
%endmacro
