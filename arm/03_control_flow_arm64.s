// ============================================================================
// File: 03_control_flow_arm64.s
// Description: Control flow: branches, loops, and conditional execution
// Topics: Branches, conditional branches, loops, compare instructions
// Assembler: GNU as (gas)
// Build: as -o 03_control_flow_arm64.o 03_control_flow_arm64.s
//        ld -o 03_control_flow_arm64 03_control_flow_arm64.o
// ============================================================================

.global _start

.section .data
    msg1:       .asciz "Loop iteration\n"
    msg2:       .asciz "Done!\n"

.section .text

_start:
    // ========================================================================
    // UNCONDITIONAL BRANCH
    // ========================================================================
    
    // B - Branch (jump) to a label
    b       start_demo             // Jump to start_demo
    
    // This code will never execute
    mov     x0, #999
    
start_demo:
    mov     x0, #1                 // This executes instead
    
    // ========================================================================
    // COMPARISON AND STATUS FLAGS
    // ========================================================================
    
    // CMP - Compare (subtracts and sets flags)
    mov     x0, #10
    mov     x1, #20
    cmp     x0, x1                 // Compare X0 with X1 (compute X0 - X1)
    
    // Sets condition flags:
    //   N (Negative), Z (Zero), C (Carry), V (Overflow)
    
    // CMN - Compare negative (adds and sets flags)
    cmn     x0, x1                 // Compare X0 with -X1 (compute X0 + X1)
    
    // TST - Test bits (AND and sets flags)
    mov     x0, #0xFF
    tst     x0, #0x0F              // Test lower 4 bits
    
    // ========================================================================
    // CONDITIONAL BRANCHES
    // ========================================================================
    
    // Condition codes:
    //   EQ  - Equal (Z=1)
    //   NE  - Not Equal (Z=0)
    //   CS/HS - Carry Set / Unsigned Higher or Same (C=1)
    //   CC/LO - Carry Clear / Unsigned Lower (C=0)
    //   MI  - Minus/Negative (N=1)
    //   PL  - Plus/Positive or Zero (N=0)
    //   VS  - Overflow Set (V=1)
    //   VC  - Overflow Clear (V=0)
    //   HI  - Unsigned Higher (C=1 && Z=0)
    //   LS  - Unsigned Lower or Same (C=0 || Z=1)
    //   GE  - Signed Greater or Equal (N==V)
    //   LT  - Signed Less Than (N!=V)
    //   GT  - Signed Greater Than (Z=0 && N==V)
    //   LE  - Signed Less or Equal (Z=1 || N!=V)
    //   AL  - Always (unconditional)
    
    mov     x0, #10
    mov     x1, #20
    cmp     x0, x1
    
    b.eq    equal_label            // Branch if equal (not taken)
    b.ne    not_equal_label        // Branch if not equal (taken)
    
equal_label:
    // Not executed
    b       after_cond
    
not_equal_label:
    // This executes
    
after_cond:
    
    // Greater than (signed)
    mov     x0, #30
    mov     x1, #20
    cmp     x0, x1
    b.gt    greater_label          // Branch if X0 > X1 (taken)
    b       after_greater
    
greater_label:
    // This executes
    
after_greater:
    
    // Less than (signed)
    mov     x0, #10
    mov     x1, #20
    cmp     x0, x1
    b.lt    less_label             // Branch if X0 < X1 (taken)
    b       after_less
    
less_label:
    // This executes
    
after_less:
    
    // ========================================================================
    // UNSIGNED VS SIGNED COMPARISONS
    // ========================================================================
    
    // For unsigned comparisons, use HI, HS, LO, LS
    // For signed comparisons, use GT, GE, LT, LE
    
    mov     x0, #0xFFFFFFFFFFFFFFFF  // -1 (signed), max (unsigned)
    mov     x1, #1
    cmp     x0, x1
    
    b.gt    signed_greater         // Not taken (signed: -1 < 1)
    b.hi    unsigned_greater       // Taken (unsigned: max > 1)
    
signed_greater:
    b       after_unsigned
    
unsigned_greater:
    // This executes
    
after_unsigned:
    
    // ========================================================================
    // COMPARE AND BRANCH (CBZ/CBNZ)
    // ========================================================================
    
    // CBZ - Compare and Branch if Zero (efficient!)
    mov     x0, #0
    cbz     x0, zero_label         // Branch if X0 == 0 (taken)
    
zero_label:
    
    // CBNZ - Compare and Branch if Not Zero
    mov     x0, #10
    cbnz    x0, not_zero_label     // Branch if X0 != 0 (taken)
    
not_zero_label:
    
    // ========================================================================
    // TEST BIT AND BRANCH (TBZ/TBNZ)
    // ========================================================================
    
    // TBZ - Test Bit and Branch if Zero
    mov     x0, #0b11110000
    tbz     x0, #0, bit_zero       // Branch if bit 0 is 0 (taken)
    
bit_zero:
    
    // TBNZ - Test Bit and Branch if Not Zero
    tbnz    x0, #7, bit_one        // Branch if bit 7 is 1 (taken)
    
bit_one:
    
    // ========================================================================
    // SIMPLE LOOP (DECREMENTING)
    // ========================================================================
    
    mov     x19, #5                // Loop counter (use callee-saved register)
    
loop_dec:
    // Loop body
    // ... do work ...
    
    subs    x19, x19, #1           // Decrement and set flags
    b.ne    loop_dec               // Branch if not zero
    
    // ========================================================================
    // SIMPLE LOOP (INCREMENTING)
    // ========================================================================
    
    mov     x19, #0                // i = 0
    
loop_inc:
    cmp     x19, #10               // Compare with limit
    b.ge    loop_inc_done          // Exit if i >= 10
    
    // Loop body
    // ... do work ...
    
    add     x19, x19, #1           // i++
    b       loop_inc
    
loop_inc_done:
    
    // ========================================================================
    // FOR LOOP PATTERN
    // ========================================================================
    
    // for (i = 0; i < 10; i++)
    
    mov     x19, #0                // i = 0
    
for_loop:
    cmp     x19, #10
    b.ge    for_done
    
    // Loop body
    // ... do work ...
    
    add     x19, x19, #1           // i++
    b       for_loop
    
for_done:
    
    // ========================================================================
    // WHILE LOOP PATTERN
    // ========================================================================
    
    // while (x19 < 100)
    
    mov     x19, #0
    
while_loop:
    cmp     x19, #100
    b.ge    while_done
    
    // Loop body
    add     x19, x19, #10
    
    b       while_loop
    
while_done:
    
    // ========================================================================
    // DO-WHILE LOOP PATTERN
    // ========================================================================
    
    // do { ... } while (x19 < 50);
    
    mov     x19, #0
    
do_while_loop:
    // Loop body (executes at least once)
    add     x19, x19, #5
    
    cmp     x19, #50
    b.lt    do_while_loop
    
    // ========================================================================
    // NESTED LOOPS
    // ========================================================================
    
    mov     x19, #0                // Outer counter
    
outer_loop:
    cmp     x19, #3
    b.ge    outer_done
    
    mov     x20, #0                // Inner counter
    
inner_loop:
    cmp     x20, #4
    b.ge    inner_done
    
    // Loop body - process x19, x20
    
    add     x20, x20, #1           // j++
    b       inner_loop
    
inner_done:
    add     x19, x19, #1           // i++
    b       outer_loop
    
outer_done:
    
    // ========================================================================
    // BREAK AND CONTINUE PATTERNS
    // ========================================================================
    
    // Loop with break
    mov     x19, #10
    
break_loop:
    cbz     x19, break_done        // Exit if zero
    
    // Check break condition
    cmp     x19, #5
    b.eq    break_done             // Break when x19 == 5
    
    subs    x19, x19, #1
    b       break_loop
    
break_done:
    
    // Loop with continue
    mov     x19, #10
    
continue_loop:
    cbz     x19, continue_done
    
    subs    x19, x19, #1
    
    // Check continue condition
    tst     x19, #1                // Test if odd
    b.eq    continue_loop          // Continue if even (skip rest)
    
    // Process odd numbers only
    // ... do work ...
    
    b       continue_loop
    
continue_done:
    
    // ========================================================================
    // SWITCH/CASE PATTERN (JUMP TABLE)
    // ========================================================================
    
    mov     x0, #1                 // Value to switch on (0-2)
    
    // Bounds check
    cmp     x0, #2
    b.hi    switch_default         // Jump to default if > 2
    
    // Load jump address from table
    adr     x1, jump_table         // Get table address
    ldr     x2, [x1, x0, lsl #3]   // Load address from table
    br      x2                     // Branch to address
    
    .align 3                       // Align to 8 bytes
jump_table:
    .dword  switch_case0
    .dword  switch_case1
    .dword  switch_case2
    
switch_case0:
    mov     x10, #0
    b       switch_end
    
switch_case1:
    mov     x10, #1
    b       switch_end
    
switch_case2:
    mov     x10, #2
    b       switch_end
    
switch_default:
    mov     x10, #-1
    
switch_end:
    
    // ========================================================================
    // CONDITIONAL SELECT (NO BRANCHING)
    // ========================================================================
    
    // CSEL - Conditional Select
    mov     x0, #10
    mov     x1, #20
    mov     x2, #100               // Value if true
    mov     x3, #200               // Value if false
    
    cmp     x0, x1
    csel    x4, x2, x3, lt         // X4 = (X0 < X1) ? X2 : X3
    // X4 = 100
    
    // Other conditional operations:
    // CSINC - Conditional Select Increment
    // CSINV - Conditional Select Invert
    // CSNEG - Conditional Select Negate
    // CSET  - Conditional Set (to 1 or 0)
    // CINC  - Conditional Increment
    
    // Example: max(a, b) without branching
    mov     x0, #15
    mov     x1, #25
    cmp     x0, x1
    csel    x2, x1, x0, gt         // X2 = (X0 > X1) ? X1 : X0
    // Actually gives min, so swap for max:
    csel    x2, x0, x1, gt         // X2 = (X0 > X1) ? X0 : X1 = max
    
    // ========================================================================
    // FUNCTION CALLS
    // ========================================================================
    
    // BL - Branch with Link (save return address in LR)
    bl      my_function            // Call function
    // Execution continues here after function returns
    
    b       after_function
    
my_function:
    // Function body
    mov     x0, #42
    ret                            // Return (branch to LR)
    
after_function:
    
    // ========================================================================
    // INDIRECT BRANCHES
    // ========================================================================
    
    // BR - Branch to Register
    adr     x0, target_label       // Get address of label
    br      x0                     // Branch to address in X0
    
target_label:
    
    // BLR - Branch with Link to Register
    adr     x0, another_target
    blr     x0                     // Call function at address
    
    b       final_label
    
another_target:
    ret
    
final_label:
    
    // ========================================================================
    // EXIT
    // ========================================================================
    
    mov     x8, #93                // sys_exit
    mov     x0, #0
    svc     #0

// ============================================================================
// NOTES:
// ============================================================================
//
// Branch Instructions:
//   B       - Unconditional branch
//   B.cond  - Conditional branch (eq, ne, gt, lt, etc.)
//   CBZ     - Compare and Branch if Zero
//   CBNZ    - Compare and Branch if Not Zero
//   TBZ     - Test Bit and Branch if Zero
//   TBNZ    - Test Bit and Branch if Not Zero
//   BL      - Branch with Link (function call)
//   BLR     - Branch with Link to Register
//   BR      - Branch to Register
//   RET     - Return (branch to LR)
//
// Comparison Instructions:
//   CMP     - Compare (subtract and set flags)
//   CMN     - Compare Negative (add and set flags)
//   TST     - Test bits (AND and set flags)
//
// Condition Codes (for B.cond):
//   EQ/NE   - Equal / Not Equal
//   GT/GE   - Greater Than / Greater or Equal (signed)
//   LT/LE   - Less Than / Less or Equal (signed)
//   HI/HS   - Higher / Higher or Same (unsigned)
//   LO/LS   - Lower / Lower or Same (unsigned)
//   MI/PL   - Minus / Plus
//   VS/VC   - Overflow Set / Clear
//
// Conditional Execution (ARM64):
//   Unlike ARM32, ARM64 doesn't support conditional execution
//   on most instructions. Use:
//   - Conditional branches (B.cond)
//   - Conditional select (CSEL and variants)
//   - Compare and branch (CBZ/CBNZ)
//
// Performance Considerations:
//   - Predictable branches are fast (branch predictor)
//   - Unpredictable branches cost 10-20 cycles
//   - Use CSEL for simple conditions (no branch)
//   - CBZ/CBNZ are efficient (compare + branch)
//   - Use jump tables for multi-way branches
//
// Best Practices:
//   - Keep loop bodies small
//   - Avoid branches in hot loops
//   - Put likely path first
//   - Use structured patterns
//   - Consider CSEL for short conditional code
//
// ============================================================================

