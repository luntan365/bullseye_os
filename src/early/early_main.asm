global kernel_early_main

section .text
    kernel_early_main:
        call enter_protected_mode
        ret

    enter_protected_mode:
        extern kernel_init_gdt
        call disable_interrupts
        call enable_a20
        call kernel_init_gdt
        call enable_nmi
        ret

    disable_interrupts:
        cli
        call disable_nmi
        ret

    enable_a20:
        ret

    enable_nmi:
        in al, 0x70
        and al, 0x7f
        out 0x70, al
        ret

    disable_nmi:
        in al, 0x70
        or al, 0x80
        out 0x70, al
        ret