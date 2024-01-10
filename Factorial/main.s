        #
        # Given a number, this program computes the factorial.
        #
        # Limitations: up to 12! because I don't know how to handle bigger numbers yet.
        #
        .section .data

format_string:
        .asciz "%d\n"

        .section .text

        .globl _start

_start:
        pushq $12       # Push the value we want to compute the factorial of.
        call factorial
        addq $8, %rsp   # Get rid of the parameter we pushed on the stack.

        # Call to printf.
        lea format_string(%rip), %rdi
        mov %rax, %rsi
        xor %eax, %eax
        call printf

        movq $60, %rax  # sys_exit system call.
        xorq %rdi, %rdi # Return with 0 now.
        syscall

        .type factorial, @function
factorial:
        pushq %rbp              # We have to restore ebp to its prior state before returoning, so push it now.
        movq %rsp, %rbp         # We don't want to modify the stack pointer, so we use ebp.
        movq 16(%rbp), %rax      # Store the first argument into eax.

        cmpq $1, %rax           # Base case, if the number is one, we finished.
        je end_factorial
        cmpq $0, %rax           # Another base case!
        je end_factorial_with_zero
        decq %rax               # Decrease the number.
        pushq %rax              # Push it on the stack and call factorial again.
        call factorial
        movq 16(%rbp), %rbx      # eax has the return value, reload our parameter into ebx.
        imulq %rbx, %rax        # Multiply that by the result of the last call to factorial. The result is in eax.

end_factorial:
        movq %rbp, %rsp         # Restore ebp and esp.
        popq %rbp
        ret

end_factorial_with_zero:
        movq $1, %rax           # The factorial of zero is one.
        jmp end_factorial
