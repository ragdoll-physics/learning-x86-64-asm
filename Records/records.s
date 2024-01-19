        .include "linux.inc"
        .include "records.inc"

        .section .bss

        .lcomm record_buffer, record_size

        .section .data

        .equ st_read_buffer, 8
        .equ st_read_fd, 12
        .equ st_write_buffer, 8
        .equ st_write_fd, 12
        .equ st_string_start_addr, 8

        .equ st_open_dat_fd, -4
        .equ st_stdout_fd, -8
newline:
        .asciz "\n"

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

        .section .text

        /* Function start. */
        .globl _start
_start:
        movl    %esp, %ebp
        subl    $4, %esp

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
        movl    st_open_dat_fd(%ebp), %ebx
        int     $syscall

        subl    $4, %esp

        /* Read records. */
        movl    $sys_open, %eax
        movl    $file_name, %ebx
        movl    $0, %ecx
        movl    $0666, %edx
        int     $syscall

        /* Assuming open doesn't fail. */
        movl    %eax, st_open_dat_fd(%ebp)
        movl    $stdout, st_stdout_fd(%ebp)

record_read_loop:
        pushl   st_open_dat_fd(%ebp)
        pushl   $record_buffer
        call    read_record
        addl    $8, %esp

        cmpl    $record_size, %eax
        jne     finished_reading
        pushl   $record_firstname + record_buffer
        call    count_chars
        addl    $4, %esp
        movl    %eax, %edx
        movl    st_stdout_fd(%ebp), %ebx
        movl    $sys_write, %eax
        movl    $record_firstname + record_buffer, %ecx
        int     $syscall

        pushl   st_stdout_fd(%ebp)
        call    write_newline
        addl    $4, %esp
        jmp     record_read_loop

finished_reading:

        /* addl    $8, %esp */

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

        /*
        * Function count_chars. Needs one argumment: a pointer to the string.
        *
        * Returns the count in %eax.
        */
        .globl count_chars
        .type count_chars, @function
count_chars:
        pushl   %ebp
        movl    %esp, %ebp

        movl    $0, %ecx
        movl    st_string_start_addr(%ebp), %edx

count_loop_begin:
        movb    (%edx), %al
        cmpb    $0, %al
        je      count_loop_end

        incl    %ecx
        incl    %edx
        jmp     count_loop_begin

count_loop_end:
        movl    %ecx, %eax
        popl    %ebp
        ret

        /*
        * Function write_newline.
        */
        .globl write_newline
        .type write_newline, @function
write_newline:
        pushl   %ebp
        movl    %esp, %ebp

        movl    $sys_write, %eax
        movl    st_write_fd(%ebp), %ebx
        movl    $newline, %ecx
        movl    $2, %edx
        int     $syscall

        movl    %ebp, %esp
        popl    %ebp
        ret
