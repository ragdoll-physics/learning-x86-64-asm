        #
        # Given a number, this program computes the factorial.
        #
        # Limitation: only up to 5! because we're using the result of the factorial as the return value
        # of our program, which only allows up to 256.
        #
        .section .data

        .section .text

        .globl _start

_start:
        pushl $5        # Push the value we want to compute the factorial of.
        call factorial
        addl $4, %esp   # Get rid of the parameter we pushed on the stack.
        movl %eax, %ebx # FACTORIAL returns the result in eax, but we want it in ebx because that's our return value.
        movl $1, %eax   # Call exit function.
        int $0x80

        .type factorial, @function
factorial:
        pushl %ebp              # We have to restore ebp to its prior state before returning, so push it now.
        movl %esp, %ebp         # We don't want to modify the stack pointer, so we use ebp.
        movl 8(%ebp), %eax      # Store the first argument into eax.

        cmpl $1, %eax           # Base case, if the number is one, we finished.
        je end_factorial
        cmpl $0, %eax           # Another base case!
        je end_factorial_with_zero
        decl %eax               # Decrease the number.
        pushl %eax              # Push it on the stack and call factorial again.
        call factorial
        movl 8(%ebp), %ebx      # eax has the return value, reload our parameter into ebx.
        imull %ebx, %eax        # Multiply that by the result of the last call to factorial. The result is in eax.

end_factorial:
        movl %ebp, %esp         # Restore ebp and esp.
        popl %ebp
        ret

end_factorial_with_zero:
        movl $1, %eax           # The factorial of zero is one.
        jmp end_factorial
