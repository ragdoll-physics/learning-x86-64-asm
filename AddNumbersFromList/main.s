        #
        # Basic program that performs a sum of all numbers that are stored in a list.
        # In this basic program, a value of 0 indicates that we reached the end of the list.
        #
        # eax -> current list element
        # edi -> current index
        # ebx -> current sum
        #
        .section .data

DataItems: .long 1, 2, 3, 4, 5, -1, 0

        .section .text

        .globl _start
_start:
        movl $0, %edi
        movl $0, %ebx
        movl DataItems(, %edi, 4), %eax # Load the first byte of data.
        addl %eax, %ebx # Add first number.

StartLoop:
        cmpl $0, %eax
        je ExitLoop
        incl %edi
        movl DataItems(, %edi, 4), %eax # Load the next number!
        addl %eax, %ebx
        jmp StartLoop

ExitLoop:
        movl $1, %eax # Store 1 in EAX for exit syscall.
        #
        # At this point, EBX will already contain the sum, so it will be used as the return value
        # of the program.
        #
        int $0x80
