.global _Reset
_Reset:
    ldr x30, =stack_top	// setup stack
    mov sp, x30
    bl main
    hlt #0
    b .
