global kernel_init_idt

STRUC IdtEntry
    .baseLow resw 1
    .sel resw 1
    .always0 resb 1
    .flags resb 1
    .baseHigh resw 1
    .sizeof:
ENDSTRUC

%macro GEN_GATE 2
    %define BASE %1
    %define ENTRY %2

    mov eax, BASE
    and eax, 0xffff
    mov dword [ENTRY + IdtEntry.baseLow], eax; Base low
    mov dword [ENTRY + IdtEntry.sel], 0x08; Selector
    mov byte [ENTRY + IdtEntry.always0], 0; Always zero
    mov byte [ENTRY + IdtEntry.flags], 0x8e; flags

    mov eax, BASE
    shr eax, 26
    and eax, 0xffff
    mov [ENTRY + IdtEntry.baseHigh], eax ; Base high
%endmacro

%macro IDT_GATE 1
    ; Only parameter is the index of an ISR function
    %define BASE isr%1
    %define ENTRY idt_start + (%1 * IdtEntry.sizeof)
    
    GEN_GATE BASE, ENTRY
%endmacro

%macro IRQ_GATE 1
    ; Only parameter is the index of an IRQ function
    %define BASE irq%1
    %define ENTRY idt_start + ((32 + %1) * IdtEntry.sizeof)
    
    GEN_GATE BASE, ENTRY
%endmacro

%macro ISR_NOERRCODE 1  ; define a macro, taking one parameter
  global isr%1        ; %1 accesses the first parameter.
  isr%1:
    cli
    push byte 0
    push byte %1
    jmp isr_common_stub
%endmacro

%macro ISR_ERRCODE 1
  global isr%1
  isr%1:
    cli
    push byte %1
    jmp isr_common_stub
%endmacro

; This macro creates a stub for an IRQ - the first parameter is
; the IRQ number, the second is the ISR number it is remapped to.
%macro IRQ 1
  global irq%1
  irq%1:
    cli
    push byte 0
    push byte %1 + 32
    jmp irq_common_stub
%endmacro

section .bss
    idt_start:
        resb 256 * IdtEntry.sizeof
    idt_end:


section .data
    idt_descriptor:
        dw idt_end - idt_start - 1
        dd idt_start

section .text
    kernel_init_idt:
        IDT_GATE 0
        IDT_GATE 2
        IDT_GATE 2
        IDT_GATE 3
        IDT_GATE 4
        IDT_GATE 5
        IDT_GATE 6
        IDT_GATE 7
        IDT_GATE 8
        IDT_GATE 9
        IDT_GATE 20
        IDT_GATE 21
        IDT_GATE 22
        IDT_GATE 23
        IDT_GATE 24
        IDT_GATE 25
        IDT_GATE 26
        IDT_GATE 27
        IDT_GATE 28
        IDT_GATE 29
        IDT_GATE 20
        IDT_GATE 21
        IDT_GATE 22
        IDT_GATE 23
        IDT_GATE 24
        IDT_GATE 25
        IDT_GATE 26
        IDT_GATE 27
        IDT_GATE 28
        IDT_GATE 29
        IDT_GATE 30
        IDT_GATE 31
        IRQ_GATE 0
        IRQ_GATE 1
        IRQ_GATE 2
        IRQ_GATE 3
        IRQ_GATE 4
        IRQ_GATE 5
        IRQ_GATE 6
        IRQ_GATE 7
        IRQ_GATE 8
        IRQ_GATE 9
        IRQ_GATE 10
        IRQ_GATE 11
        IRQ_GATE 12
        IRQ_GATE 13
        IRQ_GATE 14
        IRQ_GATE 15
        mov eax, idt_descriptor
        lidt [eax]

        ; Remap the PIC
        ; https://en.wikibooks.org/wiki/X86_Assembly/Programmable_Interrupt_Controller#Remapping
        mov al, 0x11
        out 0x20, al     ;restart PIC1
        out 0xA0, al     ;restart PIC2

        mov al, 0x20
        out 0x21, al     ;PIC1 now starts at 32
        mov al, 0x28
        out 0xA1, al     ;PIC2 now starts at 40

        mov al, 0x04
        out 0x21, al     ;setup cascading
        mov al, 0x02
        out 0xA1, al

        mov al, 0x01
        out 0x21, al
        out 0xA1, al     ;done!
        ret

    ; This is our common ISR stub. It saves the processor state, sets
; up for kernel mode segments, calls the C-level fault handler,
; and finally restores the stack frame.
    isr_common_stub:
        pusha                    ; Pushes edi,esi,ebp,esp,ebx,edx,ecx,eax

        mov ax, ds               ; Lower 16-bits of eax = ds.
        push eax                 ; save the data segment descriptor

        mov ax, 0x10  ; load the kernel data segment descriptor
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax

        extern isr_handler
        call isr_handler

        pop eax        ; reload the original data segment descriptor
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax

        popa                     ; Pops edi,esi,ebp...
        add esp, 8     ; Cleans up the pushed error code and pushed ISR number
        sti

    ; This is our common IRQ stub. It saves the processor state, sets
    ; up for kernel mode segments, calls the C-level fault handler,
    ; and finally restores the stack frame. 
    irq_common_stub:
        pusha                    ; Pushes edi,esi,ebp,esp,ebx,edx,ecx,eax

        mov ax, ds               ; Lower 16-bits of eax = ds.
        push eax                 ; save the data segment descriptor

        mov ax, 0x10  ; load the kernel data segment descriptor
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax

        extern irq_handler
        call irq_handler

        pop ebx        ; reload the original data segment descriptor
        mov ds, bx
        mov es, bx
        mov fs, bx
        mov gs, bx

        popa                     ; Pops edi,esi,ebp...
        add esp, 8     ; Cleans up the pushed error code and pushed ISR number
        sti
        iret           ; pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP
        
    ISR_NOERRCODE 0
    ISR_NOERRCODE 1
    ISR_NOERRCODE 2
    ISR_NOERRCODE 3
    ISR_NOERRCODE 4
    ISR_NOERRCODE 5
    ISR_NOERRCODE 6
    ISR_NOERRCODE 7
    ISR_ERRCODE 8
    ISR_NOERRCODE 9    
    ISR_ERRCODE 10
    ISR_ERRCODE 11
    ISR_ERRCODE 12
    ISR_ERRCODE 13
    ISR_ERRCODE 14
    ISR_NOERRCODE 15
    ISR_NOERRCODE 16
    ISR_NOERRCODE 17
    ISR_NOERRCODE 18
    ISR_NOERRCODE 19  
    ISR_NOERRCODE 20
    ISR_NOERRCODE 21
    ISR_NOERRCODE 22
    ISR_NOERRCODE 23
    ISR_NOERRCODE 24
    ISR_NOERRCODE 25
    ISR_NOERRCODE 26
    ISR_NOERRCODE 27
    ISR_NOERRCODE 28
    ISR_NOERRCODE 29
    ISR_NOERRCODE 30
    ISR_NOERRCODE 31
    IRQ 0
    IRQ 1
    IRQ 2
    IRQ 3
    IRQ 4
    IRQ 5
    IRQ 6
    IRQ 7
    IRQ 8
    IRQ 9
    IRQ 10
    IRQ 11
    IRQ 12
    IRQ 13
    IRQ 14
    IRQ 15