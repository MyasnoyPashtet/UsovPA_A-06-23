bits 16
org 0x7C00

start:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    cld

    mov ax, 0x0003
    int 0x10
    mov si, logo
    call print

    call read_yes_no
    mov si, info
    cmp al, 'y'
    je show_answer
    mov si, goodbye

show_answer:
    call print

game:
    mov si, game_intro
    call print

    xor ah, ah
    int 0x1A
    mov ax, dx
    xor dx, dx
    mov cx, 9
    div cx
    mov dh, 5

.read_guess:
    call read_key
    sub al, '1'
    cmp al, 8
    ja .read_guess
    mov si, higher
    cmp al, dl
    je .victory
    jb .wrong_guess
    mov si, lower

.wrong_guess:
    call print
    dec dh
    jnz .read_guess
    mov si, denied
    call print
    mov al, dl
    add al, '1'
    call print_char
    jmp .ask_replay

.victory:
    mov si, granted
    call print

.ask_replay:
    mov si, replay_text
    call print
    call read_yes_no
    cmp al, 'y'
    je game
    mov si, bye_text
    call print

halt:
    hlt
    jmp halt

read_yes_no:
    call read_key
    or al, 0x20
    cmp al, 'y'
    je .done
    cmp al, 'n'
    jne read_yes_no
.done:
    ret

read_key:
    xor ah, ah
    int 0x16
    ret

print:
    lodsb
    cmp al, 0
    je .done
    mov cl, 1
    cmp al, 9
    ja .repeat

    mov cl, al
    mov al, ' '
.repeat:
    call print_char
    dec cl
    jnz .repeat
    jmp print

.done:
    ret

print_char:
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    ret

logo db 'USP OS', 13, 10
     db ' _', 3, '_', 3, '____', 4, '____', 8, '___', 4, '____', 13, 10
     db '| | | | / ___|', 2, '|', 2, '_ \', 6, '/ _ \', 2, '/ ___|', 13, 10
     db '| | | | \___ \', 2, '| |_| |', 4, '| | | | \___ \', 13, 10
     db '| |_| |', 2, '___| | |', 2, '__/', 5, '| |_| |', 2, '___| |', 13, 10
     db ' \___/', 2, '|____/', 2, '|_|', 9, '\___/', 2, '|____/', 13, 10
     db 13, 10, 'Show student info? [Y/N]', 13, 10, 0

info        db 'Student: Usov Pavel A-06-23', 13, 10, 0
goodbye     db 'Okay.', 13, 10, 0
game_intro  db 'Code Breaker 1-9', 13, 10, 0
higher      db 'HIGHER', 13, 10, 0
lower       db 'LOWER', 13, 10, 0
denied      db 'ACCESS DENIED ', 0
granted     db 'ACCESS GRANTED', 0
replay_text db 13, 10, 'Again Y/N', 13, 10, 0
bye_text    db 'Bye', 0

times 510 - ($ - $$) db 0
dw 0xAA55
