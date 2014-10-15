.section INTERRUPT_VECTOR, "x"
.global _boot
_boot:
  B reset_handler /* Reset */
  B .             /* Undefined */
  B .             /* SWI */
  B .             /* Prefetch Abort */
  B .             /* Data Abort */
  B .             /* reserved */
  B .             /* IRQ */
  B .             /* FIQ */
 
reset_handler:
  LDR sp, =stack_top
  BL c_entry
  B .
