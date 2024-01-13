        #
        # I think this is the stack layout but I'm not 100% sure yet.
        #
        # --------------------------------------------- 32
        # - rsp + 32 (argv 3)                         -
        # --------------------------------------------- 24
        # - rsp + 24 (argv 2)                         -
        # --------------------------------------------- 16
        # - rsp + 16 (argv 1)                         -
        # --------------------------------------------- 8
        # - rsp + 8 (argv 0)                          -
        # --------------------------------------------- 0
        # - stack pointer, which contains argc? (rsp) -
        # ---------------------------------------------
        #
        .text
        .section .rodata

format_string:
        .string "%s\n"
        .text

format_argc:
        .string "%d\n"
        .text

        .globl main
        .type main, @function

main:
        leaq    format_argc(%rip), %rdi
        mov     (%rsp), %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax

        leaq    format_string(%rip), %rdi
        mov     8(%rsp), %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax

        leaq    format_string(%rip), %rdi
        mov     16(%rsp), %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax

        leaq    format_string(%rip), %rdi
        mov     24(%rsp), %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax

        leaq    format_string(%rip), %rdi
        mov     32(%rsp), %rsi
        movl    $0, %eax
        call    printf
        movl    $0, %eax

        movq    $60, %rax
        xorq    %rdi, %rdi
        syscall
