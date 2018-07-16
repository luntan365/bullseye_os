global kernel_init_gdt

%assign GDT_SIZE 5
%define GDT_PTR(index) (gdt_entries + (GDT_SIZE * index))

STRUC Gdt
    .size resw 1
    .offset resd 1
    .sizeof:
ENDSTRUC

STRUC GdtEntry
    .limitLow resw 1
    .baseLow resw 1
    .baseMiddle resb 1
    .access resb 1
    .granularity resb 1
    .baseHigh resb 1
    .sizeof:
ENDSTRUC

%macro GDT_FILL 5
    ; index, base, limit, granularity, access
    %define ENTRY GDT_PTR(%1)

    ; Set the base
    mov word [ENTRY + GdtEntry.baseLow], %2 & 0xffff
    mov byte [ENTRY + GdtEntry.baseMiddle], (%2 >> 16) & 0xff
    mov byte [ENTRY + GdtEntry.baseHigh], (%2 >> 24) & 0xff

    ; Set the low limit
    mov word [ENTRY + GdtEntry.limitLow], %3 & 0xffff

    ; Set the granularity
    mov byte [ENTRY + GdtEntry.granularity], ((%3 >> 16) & 0x0f) | (%4 & 0xf0)
    
    ; Set the access
    mov byte [ENTRY + GdtEntry.access], %5
%endmacro

section .data
    gdt_entries: resb (GDT_SIZE * GdtEntry.sizeof)

    gdt: ISTRUC Gdt
    AT Gdt.size, dw ((GDT_SIZE * GdtEntry.sizeof) - 1)
    AT Gdt.offset, dd gdt_entries
    IEND

section .text
    kernel_init_gdt:
        GDT_FILL 0, 0, 0, 0, 0 ; Null descriptor
        GDT_FILL 1, 0, 0xffffffff, 0x9a, 0xcf ; Code descriptor
        GDT_FILL 2, 0, 0xffffffff, 0x92, 0xcf ; Data descriptor
        GDT_FILL 3, 0, 0xffffffff, 0xfa, 0xcf ; User data descriptor
        GDT_FILL 4, 0, 0xffffffff, 0xf2, 0xcf ; User code descriptor
        push gdt
        call kernel_flush_gdt
    kernel_flush_gdt:
        pop eax
        lgdt [eax]
        mov eax, cr0
        or al, 1 ; Set protected mode bit
        mov cr0, eax
        mov ax, 0x10 ; Our data segment was loaded to 0x10.
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        jmp 0x08:.flush ; We loaded our code into 0x08 - jump there
        .flush:
        ret