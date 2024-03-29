#include <stdint.h>
#include <bullseye.h>

typedef struct
{
    uint32_t ds;                                     // Data segment selector
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax; // Pushed by pusha.
    uint32_t int_no, err_code;                       // Interrupt number and error code (if applicable)
    uint32_t eip, cs, eflags, useresp, ss;           // Pushed by the processor automatically.
} __attribute__((packed)) registers_t;

void isr_handler(registers_t regs)
{
    printf("ISR: %d\n", regs.int_no);
    // TODO: Actually do something here
    //monitor_write("recieved interrupt: ");
    //monitor_write_dec(regs.int_no);
    //monitor_put('\n');
}

// This gets called from our ASM interrupt handler stub.
void irq_handler(registers_t regs)
{
    //terminal_writestring("IRQ");
    // Send an EOI (end of interrupt) signal to the PICs.
    // If this interrupt involved the slave.
    //if (regs.int_no >= 40)
    //{
    //    // Send reset signal to slave.
    //    outb(0xA0, 0x20);
    //}
    // Send reset signal to master. (As well as slave, if necessary).
    //outb(0x20, 0x20);

    //if (regs->int_no == 32) {
    //    terminal_writestring("Hey");
    //}
    //if (interrupt_handlers[regs.int_no] != 0)
    //{
    //    isr_t handler = interrupt_handlers[regs.int_no];
    //    handler(regs);
    //}
}