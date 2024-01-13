        #
        # @TODO: Not done yet!
        #
        # This program needs two files already created.
        #
        # File 0: file with lowercase letters.
        # File 1: empty file that we'll use to write the uppercase version of file 0.
        #
        # What we'll do is:
        #
        # 0. Open the input file.
        # 1. Open the output file.
        # 2. While we're not at the end of the input file:
        #
        # 2.0) Read part of file into our buffer.
        # 2.1) Go through each byte of memory -> if it is in lowercase, convert to upper.
        # 2.2) Write the buffer to output file.
        #
        .section .data

        .equ SYS_READ, 0
        .equ SYS_WRITE, 1
        .equ SYS_OPEN, 2
        .equ SYS_CLOSE, 3
        .equ SYS_EXIT, 60
        .equ O_RDONLY, 0
        .equ O_CREAT_WRONLY_TRUNC, 03101
        .equ STDIN, 0
        .equ STDOUT, 1
        .equ STDERR, 2
        .equ END_OF_FILE, 0
        .equ BUFFSIZE, 256

        .section .bss

        .lcomm BUFFDATA, BUFFSIZE

        .section .text

        .globl _start

_start:
        # Save the stack pointer.
        movq %rsp, %rbp

        # Allocate space our two fd's (input and output file).
        subq $16, %rsp

open_fd_input_file:
        movq $SYS_OPEN, %rax
        movq 16(%rbp), %rdi
        movq $O_RDONLY, %rsi
        movq $0666, %rdx
        syscall

store_fd_in:
        movq %rax, -8(%rbp)
        xor %rax, %rax

open_fd_out:
        movq $SYS_OPEN, %rax
        movq 8(%rbp), %rdi
        movq $O_CREAT_WRONLY_TRUNC, %rsi
        movq $0666, %rdx
        syscall

store_fd_out:
        movq %rax, -16(%rbp)

read_loop_begin:
        movq $SYS_READ, %rax
        movq %rbp, %rdi
        movq $BUFFDATA, %rsi
        movq $BUFFSIZE, %rdx
        syscall

        # Check if we finished.
        cmpq $END_OF_FILE, %rax
        jle end_loop

continue_read_loop:
        pushq $BUFFDATA # Push the address of our buffer onto the stack.
        pushq %rax      # Push the size of the buffer.
        call to_upper
        popq %rax       # Get the size back.
        addq $8, %rsp   # Restore stack.

        # Write the block out to the output file.
        movq %rax, %rdx
        movq $SYS_WRITE, %rax
        movq -16(%rbp), %rdi
        movq $BUFFDATA, %rsi
        syscall
        jmp read_loop_begin

end_loop:
        movq $SYS_CLOSE, %rax
        movq -8(%rbp), %rdi
        syscall

        movq $SYS_CLOSE, %rax
        movq -16(%rbp), %rdi
        syscall

        movq $SYS_EXIT, %rax
        movq $0, %rdi
        syscall

        .type to_upper, @function
to_upper:
        #
        # Remember:
        #
        # %rax -> beginning of the buffer
        # %rbx -> length of buffer
        # %rdi -> current buffer offset
        # %cl  -> current byte being processed
        #
        .equ STACK_BUFFER_LEN, 16
        .equ STACK_BUFFER, 24

        pushq %rbp
        movq %rsp, %rbp

        movq STACK_BUFFER(%rbp), %rax
        movq STACK_BUFFER_LEN(%rbp), %rbx
        movq $0, %rdi

        # If the buffer size is 0, leave.
        cmpq $0, %rbx
        je end_convert_loop

convert_loop:
        # Get current byte.
        movb (%eax, %edi, 1), %cl

        # Go to the next byte unless it's between 'a' and 'z'.
        cmpb 'a', %cl
        jl next_byte
        cmpb 'z', %cl
        jg next_byte

        # Otherwise, convert the byte to uppercase.
        addb $32, %cl
        movb %cl, (%eax, %edi, 1)

next_byte:
        incq %rdi
        cmpq %rdi, %rdx
        jne convert_loop

end_convert_loop:
        movq %rbp, %rsp
        popq %rbp
        ret
