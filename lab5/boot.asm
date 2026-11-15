bits 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov si, message

print:
    lodsb
    test al, al
    jz halt

    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print

halt:
    jmp halt

message db 'PASHTET OS started!', 0

times 510-($-$$) db 0
dw 0xAA55