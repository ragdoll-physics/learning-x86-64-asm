        #
        # Program that computes the power of a number.
        # It will compute 2^3 + 2^5. -> 8 + 32 = 40
        #
        .section .data

        .section .text

        .globl _start

_start:
        pushl $3        # Push second argument.
        pushl $2        # Push first argument.
        call power
        addl $8, %esp   # Move the stack pointer back to where it was.

        pushl %eax      # Save the computation of 2^3
        pushl $5
        pushl $2
        call power
        addl $8, %esp   # Move the stack pointer back.

        # Now we have the second computation in %eax, and the previous
        # computation is on top of the stack, so we can pop it and store
        # it in %ebx.
        popl %ebx

        addl %eax, %ebx # Add both, store it in %ebx.

        movl $1, %eax   # Exit, the return value, which is already in %ebx, is the result of the addition.
        int $0x80

        .type power, @function
power:
        #
        # Computes the power of a number.
        #
        # First argument  -> The base number.
        # Second argument -> The power to raise it to.
        #
        # %ebx     -> holds the base number
        # %ecx     -> holds the power
        # -4(%ebp) -> holds the current result
        #
        # %eax is used for temporary storage.
        #
        pushl %ebp              # Save old base pointer.
        movl %esp, %ebp         # Make stack pointer the base pointer.
        subl $4, %esp           # Get room for local storage (4 bytes).

        movl 8(%ebp), %ebx      # Put first argument in %ebx.
        movl 12(%ebp), %ecx     # Put second argument in %ecx.

        movl %ebx, -4(%ebp)     # Store current result.

power_loop_start:
        cmpl $1, %ecx           # If the power is one, we're done.
        je end_power

        movl -4(%ebp), %eax     # Move the current result into %eax.
        imull %ebx, %eax        # Multiply the current result by this base number.
        movl %eax, -4(%ebp)     # Store the current result.

        decl %ecx               # Decrease the power.
        jmp power_loop_start

end_power:
        movl -4(%ebp), %eax     # Return value goes in %eax.
        movl %ebp, %esp         # Restore the stack pointer.
        popl %ebp               # Restore the base pointer.
        ret

