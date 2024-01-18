        .include "linux.inc"
        .include "records.inc"

        .section .data

record1:
        .asciz "Lain"
        .rept 37 /* Padding to 40 bytes */
        .byte 0
        .endr

        .asciz "Iwakura"
        .rept 34
        .byte 0
        .endr

        .asciz "Cyberia"
        .rept 32
        .byte 0
        .endr

        .long 16

record2:
        .asciz "Lain2"
        .rept 36 /* Padding to 40 bytes */
        .byte 0
        .endr

        .asciz "Iwakura2"
        .rept 33
        .byte 0
        .endr

        .asciz "Cyberia2"
        .rept 31
        .byte 0
        .endr

        .long 17

record3:
        .asciz "Lain3"
        .rept 36 /* Padding to 40 bytes */
        .byte 0
        .endr

        .asciz "Iwakura3"
        .rept 33
        .byte 0
        .endr

        .asciz "Cyberia3"
        .rept 31
        .byte 0
        .endr

        .long 18

file_name:
        .asciz "test.dat"

        .equ st_read_buffer, 8
        .equ st_read_fd, 12
        .equ st_write_buffer, 8
        .equ st_write_fd, 12
        .equ st_open_dat_fd, -4


        .section .text

        /* Function start. */
        .globl _start
_start:
        movl    %esp, %ebp
        subl    $4, %ebp

        movl    $sys_open, %eax
        movl    $file_name, %ebx
        movl    $0101, %ecx /* Mode: create file if it doesn't exist and open for writing. */
        movl    $0666, %edx
        int     $syscall

        /* Assuming it doesn't fail, of course. */
        movl    %eax, st_open_dat_fd(%ebp)

        /* Write first, second and third record. */
        pushl   st_open_dat_fd(%ebp)
        pushl   $record1
        call    write_record
        addl    $8, %esp

        pushl   st_open_dat_fd(%ebp)
        pushl   $record2
        call    write_record
        addl    $8, %esp

        pushl   st_open_dat_fd(%ebp)
        pushl   $record3
        call    write_record
        addl    $8, %esp

        movl    $sys_close, %eax
        movl    st_write_fd(%ebp), %ebx
        int     $syscall

        movl    $sys_exit, %eax
        movl    $0, %ebx
        int     $syscall

        /*
        * Function read_record. Needs two arguments: a file fd to read from and a buffer.
        * We use RAX for the return value of the syscall.
        */

        .globl read_record
        .type read_record, @function

read_record:
        pushl   %ebp
        movl    %esp, %ebp
        pushl   %ebx

        movl    st_read_fd(%ebp), %ebx
        movl    st_read_buffer(%ebp), %ecx
        movl    $record_size, %edx
        movl    $sys_read, %eax
        int     $syscall

        popl    %ebx
        movl    %ebp, %esp
        popl    %ebp
        ret

        /*
        * Function write_record. Needs two arguments: a file fd to write to and a buffer.
        * We use RAX for the return value of the syscall.
        */
        .globl write_record
        .type write_record, @function

write_record:
        pushl   %ebp
        movl    %esp, %ebp
        pushl   %ebx

        movl    $sys_write, %eax
        movl    st_write_fd(%ebp), %ebx
        movl    st_write_buffer(%ebp), %ecx
        movl    $record_size, %edx
        int     $syscall

        popl    %ebx
        movl    %ebp, %esp
        popl    %ebp
        ret
