// ============================================================================
// File: 01_hello_world_arm32.s
// Description: Basic "Hello, World!" program for ARM32 (AArch32)
// Topics: System calls, program structure, registers
// Assembler: GNU as (gas)
// Build: arm-linux-gnueabihf-as -o 01_hello_world_arm32.o 01_hello_world_arm32.s
//        arm-linux-gnueabihf-ld -o 01_hello_world_arm32 01_hello_world_arm32.o
// Note: Requires ARM32 cross-compiler or ARM32 system
// ============================================================================

.global _start

// ============================================================================
// DATA SECTION
// ============================================================================
.section .data
    msg:        .ascii "Hello, World from ARM32!\n"
    msg_len =   . - msg

// ============================================================================
// TEXT SECTION
// ============================================================================
.section .text

_start:
    // ========================================================================
    // SYSTEM CALL: write
    // ========================================================================
    // ARM32 Linux system call convention (EABI):
    //   R7 = syscall number
    //   R0 = 1st argument
    //   R1 = 2nd argument
    //   R2 = 3rd argument
    //   svc #0 or swi #0 = make system call
    //
    // Syscall numbers (ARM32 Linux EABI):
    //   write = 4
    //   exit  = 1
    
    mov     r7, #4                 @ Syscall number 4 = write
    mov     r0, #1                 @ File descriptor 1 = stdout
    ldr     r1, =msg               @ Address of string
    ldr     r2, =msg_len           @ Length of string
    svc     #0                     @ Make system call

    // ========================================================================
    // SYSTEM CALL: exit
    // ========================================================================
    
    mov     r7, #1                 @ Syscall number 1 = exit
    mov     r0, #0                 @ Exit status 0 = success
    svc     #0                     @ Make system call

// ============================================================================
// NOTES:
// ============================================================================
//
// Register Naming (ARM32):
//   R0-R12  = General purpose registers
//   R13/SP  = Stack Pointer
//   R14/LR  = Link Register (return address)
//   R15/PC  = Program Counter
//   CPSR    = Current Program Status Register (flags)
//
// System Call Convention (ARM32 EABI):
//   - R7 holds the syscall number
//   - R0-R6 hold arguments
//   - R0 returns result
//   - svc #0 (or swi #0 on older systems)
//
// Key Differences from ARM64:
//   1. Different syscall numbers (write=4 vs 64)
//   2. Syscall number in R7 instead of X8
//   3. Only 16 general purpose registers vs 31
//   4. PC (R15) is directly accessible
//   5. Most instructions can be conditionally executed
//
// Comments:
//   @ or // for single line
//   /* */ for multi-line
//
// Immediate Values:
//   ARM32 has restrictions on immediate values
//   Must be 8-bit rotated right by even amount
//   Use ldr for loading arbitrary constants: ldr r0, =value
//
// ============================================================================

