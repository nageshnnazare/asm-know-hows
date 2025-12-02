// ============================================================================
// File: 04_functions_and_stack_arm64.s
// Description: Function calls, stack operations, and calling convention
// Topics: Stack, function prologue/epilogue, AAPCS64, local variables
// Assembler: GNU as (gas)
// Build: as -o 04_functions_and_stack_arm64.o 04_functions_and_stack_arm64.s
//        ld -o 04_functions_and_stack_arm64 04_functions_and_stack_arm64.o
// ============================================================================

.global _start

.section .data
    result_msg:     .asciz "Result: "
    newline:        .asciz "\n"

.section .bss
    buffer:         .skip   64

.section .text

_start:
    // ========================================================================
    // STACK BASICS
    // ========================================================================
    
    // The stack grows DOWNWARD (from high to low addresses)
    // SP (Stack Pointer) points to the TOP of the stack (lowest used address)
    // Stack must be 16-byte aligned at function entry (AAPCS64 requirement)
    
    // Manual stack operations (not typical in functions)
    mov     x0, #0x1234567890ABCDEF
    
    // Push (store and decrement SP)
    str     x0, [sp, #-16]!        // Pre-index: SP -= 16, store X0
    
    // Pop (load and increment SP)
    ldr     x1, [sp], #16          // Post-index: load X1, SP += 16
    
    // ========================================================================
    // CALLING CONVENTION: AAPCS64
    // ========================================================================
    
    // Function Arguments:
    //   X0-X7   = Integer/pointer arguments (X0 = return value)
    //   V0-V7   = Floating-point arguments (V0 = return value)
    //   Stack   = Additional arguments
    //
    // Register Preservation:
    //   Caller-saved: X0-X18, X30 (LR), V0-V7, V16-V31
    //   Callee-saved: X19-X28, X29 (FP), SP, V8-V15 (lower 64 bits)
    //
    // Stack Alignment:
    //   Must be 16-byte aligned at function entry
    
    // ========================================================================
    // SIMPLE FUNCTION CALL
    // ========================================================================
    
    // Call add_numbers(5, 10)
    mov     x0, #5                 // First argument
    mov     x1, #10                // Second argument
    bl      add_numbers            // Branch with link (call)
    // X0 now contains 15 (return value)
    mov     x19, x0                // Save result (X19 is callee-saved)
    
    // ========================================================================
    // FUNCTION WITH MULTIPLE ARGUMENTS
    // ========================================================================
    
    // Call sum_eight(1, 2, 3, 4, 5, 6, 7, 8)
    mov     x0, #1
    mov     x1, #2
    mov     x2, #3
    mov     x3, #4
    mov     x4, #5
    mov     x5, #6
    mov     x6, #7
    mov     x7, #8
    bl      sum_eight
    // X0 = 36
    mov     x20, x0
    
    // ========================================================================
    // FUNCTION WITH STACK ARGUMENTS (More than 8 args)
    // ========================================================================
    
    // Call sum_ten(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    // Arguments 9 and 10 go on stack
    
    // Allocate stack space (must maintain 16-byte alignment)
    sub     sp, sp, #16            // Space for 2 arguments
    
    // Push arguments 9 and 10
    mov     x9, #9
    mov     x10, #10
    str     x9, [sp]               // Arg 9 at [SP+0]
    str     x10, [sp, #8]          // Arg 10 at [SP+8]
    
    // Set register arguments
    mov     x0, #1
    mov     x1, #2
    mov     x2, #3
    mov     x3, #4
    mov     x4, #5
    mov     x5, #6
    mov     x6, #7
    mov     x7, #8
    
    bl      sum_ten
    
    // Clean up stack
    add     sp, sp, #16
    // X0 = 55
    mov     x21, x0
    
    // ========================================================================
    // RECURSIVE FUNCTION
    // ========================================================================
    
    // Calculate factorial(5)
    mov     x0, #5
    bl      factorial
    // X0 = 120
    mov     x22, x0
    
    // ========================================================================
    // EXIT
    // ========================================================================
    
    mov     x8, #93                // sys_exit
    mov     x0, #0
    svc     #0

// ============================================================================
// FUNCTION: add_numbers
// Description: Adds two numbers
// Arguments: X0 = first number, X1 = second number
// Returns: X0 = sum
// ============================================================================
add_numbers:
    // Leaf function (no function calls) - no prologue needed
    // No callee-saved registers modified - no need to save
    
    add     x0, x0, x1             // X0 = X0 + X1
    ret                            // Return to caller

// ============================================================================
// FUNCTION: sum_eight
// Description: Sums eight arguments
// Arguments: X0-X7
// Returns: X0 = sum
// ============================================================================
sum_eight:
    // Leaf function, no registers to save
    
    add     x0, x0, x1
    add     x0, x0, x2
    add     x0, x0, x3
    add     x0, x0, x4
    add     x0, x0, x5
    add     x0, x0, x6
    add     x0, x0, x7
    
    ret

// ============================================================================
// FUNCTION: sum_ten
// Description: Sums ten arguments (8 in registers, 2 on stack)
// Arguments: X0-X7, [SP+0], [SP+8]
// Returns: X0 = sum
// Stack layout after BL:
//   [SP+0]  = Return address (saved by BL)
//   Note: In ARM64, BL saves LR, not on stack!
//   [SP+0]  = 9th argument
//   [SP+8]  = 10th argument
// ============================================================================
sum_ten:
    // Sum register arguments
    add     x0, x0, x1
    add     x0, x0, x2
    add     x0, x0, x3
    add     x0, x0, x4
    add     x0, x0, x5
    add     x0, x0, x6
    add     x0, x0, x7
    
    // Add stack arguments
    ldr     x9, [sp]               // Load 9th argument
    add     x0, x0, x9
    ldr     x9, [sp, #8]           // Load 10th argument
    add     x0, x0, x9
    
    ret

// ============================================================================
// FUNCTION: factorial (Recursive)
// Description: Calculates factorial recursively
// Arguments: X0 = n
// Returns: X0 = n!
// Demonstrates: Full prologue/epilogue with saved registers
// ============================================================================
factorial:
    // === PROLOGUE ===
    
    // Save frame pointer and link register
    stp     x29, x30, [sp, #-32]!  // Pre-index: SP -= 32, save FP and LR
    mov     x29, sp                // Set new frame pointer
    
    // Save callee-saved registers we'll modify
    str     x19, [sp, #16]         // Save X19
    
    // Stack layout now:
    //   [SP+0]  = old X29 (FP)
    //   [SP+8]  = old X30 (LR)
    //   [SP+16] = old X19
    //   [SP+24] = unused (for alignment)
    
    // === FUNCTION BODY ===
    
    // Base case: if n <= 1, return 1
    cmp     x0, #1
    b.gt    .Lfactorial_recursive
    
    // Base case: return 1
    mov     x0, #1
    b       .Lfactorial_return
    
.Lfactorial_recursive:
    // Recursive case: n * factorial(n-1)
    
    mov     x19, x0                // Save n in callee-saved register
    
    sub     x0, x0, #1             // n - 1
    bl      factorial              // factorial(n-1), result in X0
    
    mul     x0, x0, x19            // X0 = result * n
    
.Lfactorial_return:
    // === EPILOGUE ===
    
    // Restore saved registers
    ldr     x19, [sp, #16]
    
    // Restore frame pointer and link register
    ldp     x29, x30, [sp], #32    // Post-index: load FP and LR, SP += 32
    
    ret

// ============================================================================
// FUNCTION: multiply_with_locals
// Description: Demonstrates function with local variables
// Arguments: X0 = a, X1 = b
// Returns: X0 = a * b
// ============================================================================
multiply_with_locals:
    // === PROLOGUE ===
    
    // Save FP and LR
    stp     x29, x30, [sp, #-48]!  // Allocate 48 bytes (includes locals)
    mov     x29, sp
    
    // Save callee-saved registers (if any)
    
    // Stack frame layout:
    //   [SP+0]  = old FP
    //   [SP+8]  = old LR
    //   [SP+16] = local var 1
    //   [SP+24] = local var 2
    //   [SP+32] = local var 3
    //   [SP+40] = unused (alignment)
    
    // === FUNCTION BODY ===
    
    // Store arguments as locals
    str     x0, [sp, #16]          // local1 = a
    str     x1, [sp, #24]          // local2 = b
    
    // Do computation
    ldr     x2, [sp, #16]
    ldr     x3, [sp, #24]
    mul     x0, x2, x3             // result = a * b
    
    str     x0, [sp, #32]          // local3 = result
    ldr     x0, [sp, #32]          // Load result to return
    
    // === EPILOGUE ===
    
    ldp     x29, x30, [sp], #48    // Restore FP, LR, and deallocate
    ret

// ============================================================================
// FUNCTION: complex_function
// Description: Demonstrates complete function structure
// ============================================================================
complex_function:
    // === PROLOGUE ===
    
    // Save frame pointer and link register
    stp     x29, x30, [sp, #-64]!  // Allocate 64 bytes
    mov     x29, sp
    
    // Save callee-saved registers
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    
    // Allocate local variables
    // Already done above (64 bytes total)
    
    // === FUNCTION BODY ===
    
    // Use saved registers freely
    mov     x19, #100
    mov     x20, #200
    mov     x21, #300
    mov     x22, #400
    
    // ... function work ...
    
    // Return value
    add     x0, x19, x20
    add     x0, x0, x21
    add     x0, x0, x22
    // X0 = 1000
    
    // === EPILOGUE ===
    
    // Restore callee-saved registers
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    
    // Restore frame pointer and link register
    ldp     x29, x30, [sp], #64    // Deallocate and restore
    ret

// ============================================================================
// FUNCTION: variadic_example
// Description: Example handling variable arguments (conceptual)
// Note: Real variadic functions use va_list, this is simplified
// ============================================================================
variadic_example:
    stp     x29, x30, [sp, #-80]!
    mov     x29, sp
    
    // In AAPCS64, variadic functions receive args in X0-X7
    // Caller passes count or sentinel value
    
    // Save all register arguments to stack (va_list emulation)
    stp     x0, x1, [sp, #16]
    stp     x2, x3, [sp, #32]
    stp     x4, x5, [sp, #48]
    stp     x6, x7, [sp, #64]
    
    // Process arguments from stack
    // ...
    
    ldp     x29, x30, [sp], #80
    ret

// ============================================================================
// STACK FRAME VISUALIZATION
// ============================================================================
//
// After function prologue:
//
//   High Addresses
//   ┌──────────────────────┐
//   │  Caller's Stack      │
//   ├──────────────────────┤
//   │  Arg 9 (if any)      │  [SP at entry + 0]
//   ├──────────────────────┤
//   │  Arg 10 (if any)     │  [SP at entry + 8]
//   ├──────────────────────┤ ← SP at function entry
//   │  Saved X29 (FP)      │  [SP + 0]
//   ├──────────────────────┤
//   │  Saved X30 (LR)      │  [SP + 8]
//   ├──────────────────────┤ ← X29 (FP) points here (to saved FP)
//   │  Saved X19           │  [SP + 16]
//   ├──────────────────────┤
//   │  Saved X20           │  [SP + 24]
//   ├──────────────────────┤
//   │  Local Variable 1    │  [SP + 32]
//   ├──────────────────────┤
//   │  Local Variable 2    │  [SP + 40]
//   ├──────────────────────┤
//   │  ...                 │
//   ├──────────────────────┤ ← SP (stack pointer)
//   │  (growth direction)  │
//   └──────────────────────┘
//   Low Addresses
//
// ============================================================================
// CALLING CONVENTION SUMMARY
// ============================================================================
//
// AAPCS64 (ARM64 Procedure Call Standard):
//
// Arguments:
//   X0-X7    = Integer/pointer arguments 1-8
//   V0-V7    = Floating-point arguments 1-8
//   [SP+0..] = Additional arguments (9+)
//
// Return values:
//   X0       = Integer/pointer return
//   V0       = Floating-point return
//
// Register usage:
//   X0-X7    = Argument registers (caller-saved)
//   X8       = Indirect result location (caller-saved)
//   X9-X15   = Temporary registers (caller-saved)
//   X16-X17  = IP0, IP1 (intra-procedure-call, linker temps)
//   X18      = Platform register (reserved)
//   X19-X28  = Callee-saved registers
//   X29      = Frame Pointer (FP, callee-saved)
//   X30      = Link Register (LR, caller-saved)
//   SP       = Stack Pointer (must be preserved)
//   XZR      = Zero register
//
// Stack:
//   - Must be 16-byte aligned at public function entry
//   - Grows downward (high to low addresses)
//   - No red zone
//
// ============================================================================
// BEST PRACTICES
// ============================================================================
//
// 1. Maintain 16-byte stack alignment
// 2. Use STP/LDP for paired loads/stores (efficient)
// 3. Save FP (X29) and LR (X30) first in prologue
// 4. Save/restore callee-saved registers (X19-X28)
// 5. Use frame pointer for easier debugging
// 6. For leaf functions, omit prologue/epilogue if not needed
// 7. Document function interface (args, return, modified regs)
// 8. Use local labels (starting with .) for internal labels
//
// ============================================================================

