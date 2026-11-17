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

    mov ax, 0x0003
    int 0x10
    mov si, logo
    call print

    call read_yes_no
    cmp al, 'y'
    mov si, info
    je show_answer
    mov si, goodbye

show_answer:
    call print

game:
    mov si, game_intro
    call print

    ; Divide the low word of the BIOS tick counter by 9.
    xor ah, ah
    int 0x1A
    mov ax, dx
    xor dx, dx
    mov cx, 9
    div cx
    mov dh, 5                ; DL = secret index (0–8), DH = attempts left.

.guess:
    call read_key
    sub al, '1'              ; Convert keys '1'–'9' to indices 0–8.
    cmp al, 8
    ja .guess                ; Any other key does not use up an attempt.
    cmp al, dl
    je .won
    mov si, higher           ; MOV leaves the flags from CMP unchanged.
    jb .hint
    mov si, lower

.hint:
    call print
    dec dh
    jnz .guess
    mov si, denied
    call print
    mov al, dl
    add al, '1'
    call print_char
    jmp .replay

.won:
    mov si, granted
    call print

.replay:
    mov si, replay_text
    call print
    call read_yes_no
    cmp al, 'y'
    je game

halt:
    hlt
    jmp halt

; Ignore other keys and return 'y' or 'n' in AL.
read_yes_no:
    call read_key
    or al, 0x20
    cmp al, 'y'
    je .done
    cmp al, 'n'
    jne read_yes_no
.done:
    ret

; Wait for a key and return the ASCII character in AL.
read_key:
    push dx
    xor ah, ah
    int 0x16
    pop dx
    ret

; Print the zero-terminated string at DS:SI. Bytes 2–9 encode runs of spaces.
print:
    lodsb
    test al, al
    jz .done
    cmp al, 9
    ja .character

    mov cl, al
.space:
    mov al, ' '
    push cx
    call print_char
    pop cx
    dec cl
    jnz .space
    jmp print

.character:
    call print_char
    jmp print

.done:
    ret

print_char:
    push dx
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    pop dx
    ret

; The startup prompt follows the logo in the same string.
logo db ' _', 3, '_', 3, '____', 4, '____', 8, '___', 4, '____', 13, 10
     db '| | | | / ___|', 2, '|', 2, '_ \', 6, '/ _ \', 2, '/ ___|', 13, 10
     db '| | | | \___ \', 2, '| |_| |', 4, '| | | | \___ \', 13, 10
     db '| |_| |', 2, '___| | |', 2, '__/', 5, '| |_| |', 2, '___| |', 13, 10
     db ' \___/', 2, '|____/', 2, '|_|', 9, '\___/', 2, '|____/', 13, 10, 13, 10
     db 'Show student info? [Y/N]', 13, 10, 0

info        db 'Student: Usov Pavel A-06-23', 13, 10, 0
goodbye     db 'Okay.', 13, 10, 0
game_intro  db 13, 10, 'Code Breaker 1-9', 13, 10, 0
higher      db 'HIGHER', 13, 10, 0
lower       db 'LOWER', 13, 10, 0
denied      db 'ACCESS DENIED ', 0
granted     db 'ACCESS GRANTED', 0
replay_text db 13, 10, 'Again Y/N', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55
