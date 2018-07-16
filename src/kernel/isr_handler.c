#include <stdint.h>

typedef struct
{
    uint32_t ds;                                     // Data segment selector
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax; // Pushed by pusha.
    uint32_t int_no, err_code;                       // Interrupt number and error code (if applicable)
    uint32_t eip, cs, eflags, useresp, ss;           // Pushed by the processor automatically.
} __attribute__((packed)) registers_t;

void isr_handler(registers_t regs)
{
    // TODO: Actually do something here
    //monitor_write("recieved interrupt: ");
    //monitor_write_dec(regs.int_no);
    //monitor_put('\n');
}