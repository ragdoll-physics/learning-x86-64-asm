        /*
        ;; This program accepts two files as arguments and copies the contents of FILE1 into FILE2 but changing
        ;; lowercase letters to uppercase.
        ;;
        ;; This programs assumes that we're working under a x86-64 GNU/Linux system.
        */
        .section        .data

        .equ    sys_open, 2
        .equ    sys_close, 3
        .equ    read_only, 0
        .equ    create_wr_only_trunc, 03101
        .equ    input_filename_position, 24
        .equ    output_filename_position, 32

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
