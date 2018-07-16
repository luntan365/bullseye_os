global kernel_early_main
extern kernel_init_gdt
extern kernel_init_idt

section .text
    kernel_early_main:
        call enter_protected_mode
        ret

    enter_protected_mode:
        call disable_interrupts
        call enable_a20
        call kernel_init_gdt
        call kernel_init_idt
        call enable_nmi
        ret

    disable_interrupts:
        cli
        call disable_nmi
        ret

    enable_a20: ; Fast A20 Gate
        in al, 0x92
        test al, 2
        jnz .end
        or al, 2
        and al, 0xFE
        out 0x92, al
        jmp .end
        .end:
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