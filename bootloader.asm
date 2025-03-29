; bootloader.asm
BITS 16 ; Sets the processor to 16-bit mode
ORG 0x7C00 ; Sets the origin of the program to 0x7C00, this is needed for the BIOS to know where to load the bootloader


start:

    ; Real mode segment setup
    cli                     ; disable interrupts
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; safe stack space below bootloader
    sti                     ; re-enable interrupts

    ; BIOS TTY setup continues
    mov ah, 0x0E ; tty mode
    mov si, msg ; message to print

.print:
    lodsb ; load next byte from SI into AL
    or al, al ; check if AL is 0
    jz halt ; If AL is zero (end of string), jump to halt
    int 0x10 ; otherwise, print the character
    jmp .print ; repeat


halt:
    cli
    hlt
    jmp $


msg db 'Hai ary!!! :3', 0

; Fille the rest of the 512 bytes with 0
times 510-($-$$) db 0
dw 0xAA55
