%include 'system.inc'

section .data
        Message db "Hello to whoever reads this!", 0Ah
        MessageLength equ $-Message
section .text
global _start

_start:
        mov ebx, stdout
        mov ecx, Message
        mov edx, MessageLength
        sys.write

        mov eax, 0
        sys.exit
