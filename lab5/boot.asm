bits 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    cld
    sti

    mov ax, 0x0003            ; Set text mode and clear the screen.
    int 0x10

    mov si, logo
    call print
    mov si, question
    call print

read_answer:
    xor ah, ah                ; Wait for a key and get its ASCII code in AL.
    int 0x16
    or al, 0x20               ; Accept both uppercase and lowercase Y/N.
    cmp al, 'y'
    je show_info
    cmp al, 'n'
    jne read_answer

    mov si, goodbye
    jmp show_answer

show_info:
    mov si, info

show_answer:
    call print

halt:
    hlt
    jmp halt

; Print the zero-terminated string at DS:SI.
print:
    lodsb
    test al, al
    jz .done

    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print

.done:
    ret

logo db ' _   _   ____    ____        ___    ____', 13, 10
     db '| | | | / ___|  |  _ \      / _ \  / ___|', 13, 10
     db '| | | | \___ \  | |_| |    | | | | \___ \', 13, 10
     db '| |_| |  ___| | |  __/     | |_| |  ___| |', 13, 10
     db ' \___/  |____/  |_|         \___/  |____/', 13, 10, 13, 10, 0

question db 'Show student info? [Y/N]', 13, 10, 0
info     db 'Student: Usov Pavel A-06-23', 13, 10, 0
goodbye  db 'Okay.', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55
