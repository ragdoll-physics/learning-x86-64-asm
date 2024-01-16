        /*
        This program accepts two files as arguments and copies the contents of FILE1 into FILE2 but changing
        lowercase letters to uppercase.

        This programs assumes that we're working under a x86-64 GNU/Linux system.

        TO DO: need to figure out why the first argument of our program is at byte %rsp + 24 and why the second
        one is at %rsp + 32.
        */
        .section        .data

        .equ    sys_read, 0
        .equ    sys_open, 2
        .equ    sys_close, 3
        .equ    sys_write, 1
        .equ    read_only, 0
        .equ    create_wr_only_trunc, 03101
        .equ    input_filename_position, 24
        .equ    output_filename_position, 32
        .equ    lowercase_a, 'a'
        .equ    lowercase_z, 'z'

        .section        .bss

        .equ    buffer_size, 500
        .lcomm  buffer_data, buffer_size

        .section        .text

str_err_wrong_number_of_arguments:
        .asciz  "Usage: ./main <input_file> <output_file>"

str_err_couldnt_open_input_file:
        .asciz "Could not open input file"

str_err_couldnt_open_output_file:
        .asciz "Could not open output file"

str_err_couldnt_close_input_file:
        .asciz "Could not close input file"

str_err_couldnt_close_output_file:
        .asciz "Could not close output file"

string_fmt:
        .asciz  "%s\n"

        .globl  main
        .type   main, @function

main:
        /* Check number of arguments. */
        cmpl    $3, (%rsp)
        jne     err_exit_with_wrong_arguments

        /* Reserve space for two fds. */
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $16, %rsp

        /* Open both files first and check if any error ocurred. */
        movq    $sys_open, %rax
        mov     input_filename_position(%rbp), %rdi
        movq    $read_only, %rsi
        movq    $0666, %rdx
        syscall

        cmpq    $0, %rax
        jle     err_couldnt_open_input_file

        /* Save fd. */
        movq    %rax, -8(%rbp)

        /* Same thing for output file. */
        movq    $sys_open, %rax
        mov     output_filename_position(%rbp), %rdi
        movq    $create_wr_only_trunc, %rsi
        movq    $0666, %rdx
        syscall

        cmpq    $0, %rax
        jle     err_couldnt_open_output_file

        movq    %rax, -16(%rbp)

read_loop:
        movq    $sys_read, %rax
        movq    -8(%rbp), %rdi
        movq    $buffer_data, %rsi
        movq    $buffer_size, %rdx
        syscall

        cmpq    $0, %rax
        jle     end_loop

        pushq   $buffer_data /* @TODO Why are we pushing the buffer's address when we already have it? */
        pushq   %rax /* Size of the buffer. */
        call    convert_to_upper
        popq    %rax
        addq    $8, %rsp

        /* Write the buffer. */
        movq    %rax, %rdx /* Size of the buffer is here. */
        movq    $sys_write, %rax
        movq    -16(%rbp), %rdi /* fd of output file. */
        movq    $buffer_data, %rsi
        syscall

        jmp     read_loop

end_loop:
        /* Close files. */
        movq    $sys_close, %rax
        movq    -8(%rbp), %rdi
        syscall

        cmpq    $0, %rax
        jl      err_closing_input_file

        movq    $sys_close, %rax
        movq    -16(%rbp), %rdi
        syscall

        cmpq    $0, %rax
        jl      err_closing_output_file

        jmp     exit

err_exit_with_wrong_arguments:
        leaq    string_fmt(%rip), %rdi
        mov     $str_err_wrong_number_of_arguments, %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax
        jmp     exit

err_couldnt_open_input_file:
        leaq    string_fmt(%rip), %rdi
        mov     $str_err_couldnt_open_input_file, %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax
        jmp     exit

err_couldnt_open_output_file:
        leaq    string_fmt(%rip), %rdi
        mov     $str_err_couldnt_open_output_file, %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax
        jmp     exit

err_closing_input_file:
        leaq    string_fmt(%rip), %rdi
        mov     $str_err_couldnt_close_input_file, %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax
        jmp     exit

err_closing_output_file:
        leaq    string_fmt(%rip), %rdi
        mov     $str_err_couldnt_close_output_file, %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax
        jmp     exit

exit:
        movq    $60, %rax
        movq    $0, %rdi
        syscall
        leave
        ret

        /* Function convert_to_upper */
        .type   convert_to_upper, @function
convert_to_upper:
        pushq   %rbp
        movq    %rsp, %rbp

        movq    24(%rbp), %rax /* Buffer's data. */
        movq    16(%rbp), %rbx /* Buffer's size. */
        movq    $0, %rdi

        cmpq    $0, %rbx
        je      end_convert_loop

convert_loop:

        /* Get the character in cl. */
        movb    (%rax, %rdi, 1), %cl

        /* Go to the next byte unless it's between ['a', 'z']. */
        cmpb    $lowercase_a, %cl
        jl      next_byte
        cmpb    $lowercase_z, %cl
        jg      next_byte

        /* Otherwise, we need to convert it to uppercase! */
        subb    $32, %cl

        /* Store it back! */
        movb    %cl, (%rax, %rdi, 1)

next_byte:
        incq    %rdi

        /* Check if we got to the end. */
        cmpq    %rdi, %rbx
        jne     convert_loop

end_convert_loop:
        leave
        ret
