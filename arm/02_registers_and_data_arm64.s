// ============================================================================
// File: 02_registers_and_data_arm64.s
// Description: Demonstrates register operations and data manipulation (ARM64)
// Topics: Registers, mov instructions, arithmetic, logical operations
// Assembler: GNU as (gas)
// Build: as -o 02_registers_and_data_arm64.o 02_registers_and_data_arm64.s
//        ld -o 02_registers_and_data_arm64 02_registers_and_data_arm64.o
// ============================================================================

.global _start

.section .data
    // Different data types
    byte_val:       .byte   0xFF                // 8-bit value
    half_val:       .hword  0xFFFF              // 16-bit value
    word_val:       .word   0xFFFFFFFF          // 32-bit value
    dword_val:      .dword  0xFFFFFFFFFFFFFFFF  // 64-bit value
    
    // Arrays
    byte_array:     .byte   10, 20, 30, 40, 50
    word_array:     .word   100, 200, 300, 400
    dword_array:    .dword  1000, 2000, 3000, 4000
    
    // Strings
    string:         .asciz  "Test String"       // Null-terminated
    
    // Floating point
    float_val:      .float  3.14159
    double_val:     .double 2.718281828

.section .bss
    // Uninitialized data
    buffer:         .skip   64                  // Reserve 64 bytes
    counter:        .skip   8                   // Reserve 8 bytes

.section .text

_start:
    // ========================================================================
    // BASIC REGISTER OPERATIONS
    // ========================================================================
    
    // Move immediate values to registers
    mov     x0, #42                // X0 = 42
    mov     x1, #0x1000            // X1 = 4096 (hex)
    mov     x2, #-1                // X2 = -1 (0xFFFFFFFFFFFFFFFF)
    
    // Large immediates may require multiple instructions
    movz    x3, #0x1234, lsl #16   // Move with zero (shift left 16)
    movk    x3, #0x5678            // Move with keep (set lower 16 bits)
    // X3 = 0x0000000012345678
    
    // ========================================================================
    // REGISTER-TO-REGISTER MOVES
    // ========================================================================
    
    mov     x4, x0                 // Copy X0 to X4
    mov     x5, x1                 // Copy X1 to X5
    
    // ========================================================================
    // ACCESSING DIFFERENT REGISTER SIZES
    // ========================================================================
    
    // ARM64 has 64-bit (X) and 32-bit (W) views
    mov     x0, #0x123456789ABCDEF0
    
    // X0 = 0x123456789ABCDEF0 (64-bit)
    // W0 = 0x9ABCDEF0 (lower 32 bits)
    
    // Writing to W register zeros upper 32 bits!
    mov     w0, #100               // X0 = 0x0000000000000064
    
    // ========================================================================
    // ARITHMETIC OPERATIONS
    // ========================================================================
    
    // Addition
    mov     x0, #10
    mov     x1, #20
    add     x2, x0, x1             // X2 = X0 + X1 = 30
    
    // Add with immediate
    add     x2, x0, #5             // X2 = X0 + 5 = 15
    
    // Subtraction
    sub     x3, x1, x0             // X3 = X1 - X0 = 10
    sub     x3, x1, #5             // X3 = X1 - 5 = 15
    
    // Multiply
    mov     x0, #5
    mov     x1, #3
    mul     x2, x0, x1             // X2 = X0 * X1 = 15
    
    // Multiply and accumulate
    mov     x3, #100
    madd    x4, x0, x1, x3         // X4 = (X0 * X1) + X3 = 115
    
    // Multiply and subtract
    msub    x5, x0, x1, x3         // X5 = X3 - (X0 * X1) = 85
    
    // Division (unsigned)
    mov     x0, #20
    mov     x1, #3
    udiv    x2, x0, x1             // X2 = X0 / X1 = 6 (unsigned)
    
    // Division (signed)
    mov     x0, #-20
    mov     x1, #3
    sdiv    x2, x0, x1             // X2 = X0 / X1 = -6 (signed)
    
    // Remainder (manual calculation)
    mov     x0, #20
    mov     x1, #3
    udiv    x2, x0, x1             // Quotient
    msub    x3, x2, x1, x0         // Remainder: X0 - (quotient * X1)
    // X3 = 2 (20 mod 3)
    
    // Negate
    mov     x0, #10
    neg     x1, x0                 // X1 = -X0 = -10
    
    // ========================================================================
    // LOGICAL OPERATIONS
    // ========================================================================
    
    // AND - Bitwise AND
    mov     x0, #0b11110000        // 0xF0
    mov     x1, #0b11001100        // 0xCC
    and     x2, x0, x1             // X2 = 0xC0 (0b11000000)
    
    // OR - Bitwise OR
    orr     x2, x0, x1             // X2 = 0xFC (0b11111100)
    
    // XOR - Bitwise exclusive OR
    eor     x2, x0, x1             // X2 = 0x3C (0b00111100)
    
    // NOT - Bitwise complement (using MVN)
    mvn     x2, x0                 // X2 = ~X0
    
    // Clear a register (idiom)
    eor     x0, x0, x0             // X0 = 0 (or just mov x0, #0)
    
    // Bit clear (AND NOT)
    bic     x2, x0, x1             // X2 = X0 & ~X1
    
    // Bitwise OR NOT
    orn     x2, x0, x1             // X2 = X0 | ~X1
    
    // Test bits (doesn't store result, only sets flags)
    mov     x0, #0xFF
    tst     x0, #0x0F              // Test if any of lower 4 bits set
    
    // ========================================================================
    // SHIFT AND ROTATE OPERATIONS
    // ========================================================================
    
    // Logical shift left
    mov     x0, #5                 // 0b101
    lsl     x1, x0, #1             // X1 = 10 (0b1010) - multiply by 2
    lsl     x1, x0, #2             // X1 = 20 (0b10100) - multiply by 4
    
    // Logical shift right (unsigned)
    mov     x0, #20
    lsr     x1, x0, #1             // X1 = 10 - divide by 2
    lsr     x1, x0, #2             // X1 = 5 - divide by 4
    
    // Arithmetic shift right (signed - preserves sign bit)
    mov     x0, #-40
    asr     x1, x0, #2             // X1 = -10 (signed divide by 4)
    
    // Rotate right
    mov     x0, #0x8000000000000001
    ror     x1, x0, #1             // Rotate right by 1
    // X1 = 0xC000000000000000
    
    // ========================================================================
    // BIT FIELD OPERATIONS
    // ========================================================================
    
    // Extract bits
    mov     x0, #0x12345678
    ubfx    x1, x0, #8, #8         // Extract 8 bits from bit 8
    // X1 = 0x56
    
    // Insert bits
    mov     x0, #0xFFFFFFFFFFFFFFFF
    mov     x1, #0x42
    bfi     x0, x1, #8, #8         // Insert X1[7:0] into X0[15:8]
    // X0 = 0xFFFFFFFFFFFF42FF
    
    // ========================================================================
    // LOADING FROM MEMORY
    // ========================================================================
    
    // Load different sizes
    ldr     x0, =byte_val          // Get address
    ldrb    w1, [x0]               // Load byte (zero-extend)
    
    ldr     x0, =half_val
    ldrh    w1, [x0]               // Load halfword (16-bit)
    
    ldr     x0, =word_val
    ldr     w1, [x0]               // Load word (32-bit)
    
    ldr     x0, =dword_val
    ldr     x1, [x0]               // Load doubleword (64-bit)
    
    // Sign-extending loads
    ldr     x0, =byte_val
    ldrsb   x1, [x0]               // Load signed byte
    
    // ========================================================================
    // STORING TO MEMORY
    // ========================================================================
    
    mov     x0, #42
    ldr     x1, =counter
    str     x0, [x1]               // Store 64-bit value
    
    mov     w0, #100
    ldr     x1, =buffer
    strb    w0, [x1]               // Store byte
    
    // ========================================================================
    // ADDRESSING MODES
    // ========================================================================
    
    ldr     x0, =dword_array
    
    // Base register only
    ldr     x1, [x0]               // Load from [X0]
    
    // Base + offset
    ldr     x1, [x0, #8]           // Load from [X0 + 8]
    
    // Pre-indexed (update base)
    ldr     x1, [x0, #8]!          // X0 += 8, then load
    
    // Post-indexed (update base after load)
    ldr     x1, [x0], #8           // Load, then X0 += 8
    
    // Base + register offset
    mov     x2, #16
    ldr     x1, [x0, x2]           // Load from [X0 + X2]
    
    // With scaling
    mov     x2, #2                 // Index
    ldr     x1, [x0, x2, lsl #3]   // Load from [X0 + (X2 << 3)]
    // Useful for array indexing: array[i] where elements are 8 bytes
    
    // ========================================================================
    // LOAD/STORE PAIR
    // ========================================================================
    
    // Load pair (loads two registers)
    ldr     x0, =dword_array
    ldp     x1, x2, [x0]           // X1 = [X0], X2 = [X0+8]
    
    // Store pair
    mov     x1, #100
    mov     x2, #200
    ldr     x0, =buffer
    stp     x1, x2, [x0]           // Store X1 and X2 to memory
    
    // Load/store pair with update
    ldr     x0, =dword_array
    ldp     x1, x2, [x0], #16      // Load, then X0 += 16
    
    // ========================================================================
    // CONDITIONAL SELECT
    // ========================================================================
    
    // Select based on condition (no branching!)
    mov     x0, #10
    mov     x1, #20
    cmp     x0, x1                 // Compare X0 and X1
    csel    x2, x0, x1, lt         // X2 = (X0 < X1) ? X0 : X1
    // X2 = 10 (min of X0 and X1)
    
    // Conditional increment
    mov     x0, #5
    mov     x1, #1
    cmp     x0, #10
    cinc    x2, x1, lt             // X2 = (X0 < 10) ? X1+1 : X1
    // X2 = 2
    
    // ========================================================================
    // ZERO REGISTER
    // ========================================================================
    
    // XZR always reads as 0, writes are ignored
    mov     x0, #100
    add     x1, x0, xzr            // X1 = X0 + 0 = 100
    
    // Useful for clearing memory
    ldr     x0, =buffer
    str     xzr, [x0]              // Store 0 to memory
    
    // ========================================================================
    // EXIT
    // ========================================================================
    
    mov     x8, #93                // sys_exit
    mov     x0, #0                 // Exit code 0
    svc     #0

// ============================================================================
// NOTES:
// ============================================================================
//
// Register Naming:
//   X0-X30  = 64-bit registers
//   W0-W30  = 32-bit views (lower half)
//   XZR/WZR = Zero register
//   SP      = Stack pointer
//   X30/LR  = Link register
//   X29/FP  = Frame pointer
//
// Important Instruction Forms:
//   mov  Xd, Xn          - Copy register
//   mov  Xd, #imm        - Load immediate
//   movz Xd, #imm        - Move with zero
//   movk Xd, #imm        - Move with keep (doesn't clear other bits)
//   movn Xd, #imm        - Move with NOT
//
// Arithmetic:
//   add, sub, mul, madd, msub, udiv, sdiv, neg
//
// Logical:
//   and, orr, eor, mvn, bic, orn, tst
//
// Shifts:
//   lsl, lsr, asr, ror
//
// Bit Fields:
//   ubfx (extract unsigned), sbfx (extract signed)
//   bfi (insert), bfc (clear)
//
// Load/Store:
//   ldr, str (various sizes: ldrb, ldrh, ldrsb, ldrsh, etc.)
//   ldp, stp (load/store pair)
//
// Addressing Modes:
//   [Xn]              - Base only
//   [Xn, #imm]        - Base + offset
//   [Xn, #imm]!       - Pre-indexed
//   [Xn], #imm        - Post-indexed
//   [Xn, Xm]          - Base + register
//   [Xn, Xm, lsl #n]  - Base + scaled register
//
// ============================================================================

