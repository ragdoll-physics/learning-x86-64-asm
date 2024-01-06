        #
        # Basic program that returns the highest number from a list.
        # In this basic program, a value of 0 indicates that we reached the end of the list.
        #
        # eax -> current list element
        # edi -> current index
        # ebx -> highest element in the list
        #
        .section .data

DataItems:
        #
        # The maximum value allowed is 255. This is because it's the largest value allowed as a exit status of a program.
        # Long permits values from 0 to 4294967295.
        #
        .long 3,67,34,223,45,75,54,34,44,33,22,11,66,255,0

        .section .text

        .globl _start
_start:
        movl $0, %edi
        movl DataItems(,%edi,4), %eax # Load the first byte of data.
        movl %eax, %ebx # The first number is already the highest, store it in EBX.

StartLoop:
        cmpl $0, %eax
        je ExitLoop
        incl %edi
        movl DataItems(,%edi,4), %eax # Load the next number!

        cmpl %ebx, %eax
        jle StartLoop # Number is not higher, so keep looping.
        movl %eax, %ebx # Number was higher, so store it in EBX and keep traversing.
        jmp StartLoop

ExitLoop:
        movl $1, %eax # Store 1 in EAX for exit syscall.
        #
        # At this point, EBX will already contain the highest number, so it will be used as the return value
        # of the program.
        #
        int $0x80
