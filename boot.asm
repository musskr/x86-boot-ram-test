[org 0x7C00]
[bits 16]

MARKER_ADDR equ 0x100000
MARKER_VAL  equ 0xDEADBEEF

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    lgdt [gdt_desc]
    mov eax, cr0
    or  al, 1
    mov cr0, eax
    jmp 0x08:pm_entry

[bits 32]
pm_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov eax, cr0
    and al, 0xFE
    mov cr0, eax
    jmp 0x00:unreal_entry

[bits 16]
unreal_entry:
    mov eax, [MARKER_ADDR]
    cmp eax, MARKER_VAL
    je  .survived

    mov dword [MARKER_ADDR], MARKER_VAL
    mov si, msg_first
    call print

    lidt [null_idt]
    int 3
    jmp $

.survived:
    mov si, msg_survived
    call print
    jmp $

print:
    mov ah, 0x0E
.next:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .next
.done:
    ret

msg_first    db "BOOT 1: marker written, forcing reset...", 13, 10, 0
msg_survived db "BOOT 2: marker survived reset! RAM not cleared.", 13, 10, 0

gdt_start:
    dq 0
gdt_code:
    dw 0xFFFF, 0x0000
    db 0x00, 10011010b, 11001111b, 0x00
gdt_data:
    dw 0xFFFF, 0x0000
    db 0x00, 10010010b, 11001111b, 0x00
gdt_end:

gdt_desc:
    dw gdt_end - gdt_start - 1
    dd gdt_start

null_idt:
    dw 0
    dd 0

times 510 - ($ - $$) db 0
dw 0xAA55