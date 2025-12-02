// ============================================================================
// File: 01_hello_world_arm64.s
// Description: Basic "Hello, World!" program for ARM64 (AArch64)
// Topics: System calls, program structure, registers
// Assembler: GNU as (gas)
// Build: as -o 01_hello_world_arm64.o 01_hello_world_arm64.s
//        ld -o 01_hello_world_arm64 01_hello_world_arm64.o
// Run: ./01_hello_world_arm64
// ============================================================================

// The .global directive makes _start visible to the linker
.global _start

// ============================================================================
// DATA SECTION - Contains initialized data
// ============================================================================
.section .data
    // Define message string
    msg:        .ascii "Hello, World!\n"
    msg_len =   . - msg                    // Calculate length

// ============================================================================
// TEXT SECTION - Contains executable code
// ============================================================================
.section .text

_start:
    // ========================================================================
    // SYSTEM CALL: write
    // ========================================================================
    // Write "Hello, World!" to stdout (file descriptor 1)
    //
    // ARM64 Linux system call convention:
    //   X8  = syscall number
    //   X0  = 1st argument (file descriptor)
    //   X1  = 2nd argument (buffer pointer)
    //   X2  = 3rd argument (byte count)
    //   svc #0 = make system call
    //
    // Syscall numbers (ARM64 Linux):
    //   write = 64
    //   exit  = 93
    
    mov     x8, #64                // Syscall number 64 = write
    mov     x0, #1                 // File descriptor 1 = stdout
    ldr     x1, =msg               // Address of string (pseudo-instruction)
    mov     x2, #msg_len           // Length of string
    svc     #0                     // Make system call

    // ========================================================================
    // SYSTEM CALL: exit
    // ========================================================================
    // Exit the program with return code 0 (success)
    
    mov     x8, #93                // Syscall number 93 = exit
    mov     x0, #0                 // Exit status 0 = success
    svc     #0                     // Make system call

// ============================================================================
// NOTES:
// ============================================================================
//
// Register Naming (ARM64):
//   X0-X30  = 64-bit general purpose registers
//   W0-W30  = 32-bit views of X0-X30 (lower 32 bits)
//   SP      = Stack Pointer
//   XZR/WZR = Zero register (always reads as 0, writes ignored)
//   X30/LR  = Link Register (holds return address)
//   X29/FP  = Frame Pointer
//
// System Call Convention:
//   - X8 holds the syscall number
//   - X0-X5 hold arguments (up to 6)
//   - X0 returns result
//   - svc #0 triggers supervisor call
//
// Important Differences from x86_64:
//   1. Different syscall numbers (write=64 vs 1)
//   2. Syscall number in X8, not X0/RAX
//   3. svc #0 instead of syscall instruction
//   4. Load/store architecture (can't operate on memory directly)
//
// Pseudo-instructions:
//   ldr x1, =label  - Load address of label (expands to multiple instructions)
//   mov x0, #large  - May expand if immediate doesn't fit
//
// File Descriptors:
//   0 = stdin  (standard input)
//   1 = stdout (standard output)
//   2 = stderr (standard error)
//
// ============================================================================

