// ============================================================================
// File: 05_neon_simd_arm64.s
// Description: NEON SIMD programming for ARM64
// Topics: Vector registers, NEON instructions, vectorization
// Assembler: GNU as (gas)
// Build: as -o 05_neon_simd_arm64.o 05_neon_simd_arm64.s
//        ld -o 05_neon_simd_arm64 05_neon_simd_arm64.o
// ============================================================================

.global _start

.section .data
    // Aligned data (16-byte alignment for NEON)
    .align 4
    float_array1:   .float 1.0, 2.0, 3.0, 4.0    // 4 floats
    .align 4
    float_array2:   .float 5.0, 6.0, 7.0, 8.0
    
    .align 4
    int_array1:     .word 1, 2, 3, 4              // 4 32-bit integers
    .align 4
    int_array2:     .word 10, 20, 30, 40
    
    .align 4
    byte_array:     .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16

.section .bss
    .align 4
    result_array:   .skip   64

.section .text

_start:
    // ========================================================================
    // NEON REGISTER OVERVIEW
    // ========================================================================
    
    // ARM64 has 32 128-bit SIMD registers: V0-V31
    // Can be accessed as:
    //   V registers (128-bit)  - Full vector
    //   Q registers (128-bit)  - Quadword view
    //   D registers (64-bit)   - Doubleword view (lower half)
    //   S registers (32-bit)   - Single word view
    //   H registers (16-bit)   - Halfword view
    //   B registers (8-bit)    - Byte view
    
    // ========================================================================
    // LOADING AND STORING VECTORS
    // ========================================================================
    
    // Load 128-bit vector (4 floats)
    ldr     x0, =float_array1
    ld1     {v0.4s}, [x0]          // Load 4 single-precision floats
    // v0 = [1.0, 2.0, 3.0, 4.0]
    
    ldr     x0, =float_array2
    ld1     {v1.4s}, [x0]
    // v1 = [5.0, 6.0, 7.0, 8.0]
    
    // Load integers
    ldr     x0, =int_array1
    ld1     {v2.4s}, [x0]          // Load 4 32-bit integers
    // v2 = [1, 2, 3, 4]
    
    // Store vector
    ldr     x0, =result_array
    st1     {v0.4s}, [x0]          // Store 4 floats
    
    // Load byte vector
    ldr     x0, =byte_array
    ld1     {v3.16b}, [x0]         // Load 16 bytes
    
    // ========================================================================
    // VECTOR ARITHMETIC (Floating Point)
    // ========================================================================
    
    // Add vectors (4 floats at once)
    ldr     x0, =float_array1
    ldr     x1, =float_array2
    ld1     {v0.4s}, [x0]          // v0 = [1.0, 2.0, 3.0, 4.0]
    ld1     {v1.4s}, [x1]          // v1 = [5.0, 6.0, 7.0, 8.0]
    fadd    v2.4s, v0.4s, v1.4s    // v2 = [6.0, 8.0, 10.0, 12.0]
    
    // Subtract vectors
    fsub    v3.4s, v1.4s, v0.4s    // v3 = [4.0, 4.0, 4.0, 4.0]
    
    // Multiply vectors
    fmul    v4.4s, v0.4s, v1.4s    // v4 = [5.0, 12.0, 21.0, 32.0]
    
    // Divide vectors
    fdiv    v5.4s, v1.4s, v0.4s    // v5 = [5.0, 3.0, 2.333..., 2.0]
    
    // Multiply-accumulate
    fmla    v2.4s, v0.4s, v1.4s    // v2 = v2 + (v0 * v1)
    
    // Multiply-subtract
    fmls    v2.4s, v0.4s, v1.4s    // v2 = v2 - (v0 * v1)
    
    // ========================================================================
    // VECTOR ARITHMETIC (Integer)
    // ========================================================================
    
    // Load integer vectors
    ldr     x0, =int_array1
    ldr     x1, =int_array2
    ld1     {v0.4s}, [x0]          // v0 = [1, 2, 3, 4]
    ld1     {v1.4s}, [x1]          // v1 = [10, 20, 30, 40]
    
    // Add (4 integers)
    add     v2.4s, v0.4s, v1.4s    // v2 = [11, 22, 33, 44]
    
    // Subtract
    sub     v3.4s, v1.4s, v0.4s    // v3 = [9, 18, 27, 36]
    
    // Multiply
    mul     v4.4s, v0.4s, v1.4s    // v4 = [10, 40, 90, 160]
    
    // Multiply-accumulate
    mla     v2.4s, v0.4s, v1.4s    // v2 = v2 + (v0 * v1)
    
    // Multiply-subtract
    mls     v2.4s, v0.4s, v1.4s    // v2 = v2 - (v0 * v1)
    
    // ========================================================================
    // VECTOR WIDTH VARIATIONS
    // ========================================================================
    
    // Operations on different element sizes:
    
    // 16 bytes (16 x 8-bit)
    ldr     x0, =byte_array
    ld1     {v0.16b}, [x0]
    add     v1.16b, v0.16b, v0.16b // Add 16 bytes
    
    // 8 halfwords (8 x 16-bit)
    add     v1.8h, v0.8h, v0.8h    // Add 8 halfwords
    
    // 4 words (4 x 32-bit)
    add     v1.4s, v0.4s, v0.4s    // Add 4 words
    
    // 2 doublewords (2 x 64-bit)
    add     v1.2d, v0.2d, v0.2d    // Add 2 doublewords
    
    // ========================================================================
    // COMPARISON OPERATIONS
    // ========================================================================
    
    // Compare equal (result is mask: all 1s or all 0s per element)
    ldr     x0, =float_array1
    ldr     x1, =float_array2
    ld1     {v0.4s}, [x0]
    ld1     {v1.4s}, [x1]
    
    fcmeq   v2.4s, v0.4s, v1.4s    // v2 = (v0 == v1) ? 0xFFFFFFFF : 0
    
    // Compare greater than
    fcmgt   v3.4s, v1.4s, v0.4s    // v3 = (v1 > v0) ? 0xFFFFFFFF : 0
    
    // Compare greater or equal
    fcmge   v4.4s, v1.4s, v0.4s    // v4 = (v1 >= v0) ? 0xFFFFFFFF : 0
    
    // Integer comparisons
    ldr     x0, =int_array1
    ldr     x1, =int_array2
    ld1     {v0.4s}, [x0]
    ld1     {v1.4s}, [x1]
    
    cmeq    v2.4s, v0.4s, v1.4s    // Equal
    cmgt    v3.4s, v1.4s, v0.4s    // Greater than (signed)
    cmge    v4.4s, v1.4s, v0.4s    // Greater or equal (signed)
    cmhi    v5.4s, v1.4s, v0.4s    // Higher (unsigned)
    
    // ========================================================================
    // LOGICAL OPERATIONS
    // ========================================================================
    
    // Bitwise AND
    and     v2.16b, v0.16b, v1.16b
    
    // Bitwise OR
    orr     v3.16b, v0.16b, v1.16b
    
    // Bitwise XOR
    eor     v4.16b, v0.16b, v1.16b
    
    // Bitwise NOT
    mvn     v5.16b, v0.16b
    
    // Bitwise clear (AND NOT)
    bic     v6.16b, v0.16b, v1.16b
    
    // ========================================================================
    // MIN/MAX OPERATIONS
    // ========================================================================
    
    ldr     x0, =float_array1
    ldr     x1, =float_array2
    ld1     {v0.4s}, [x0]
    ld1     {v1.4s}, [x1]
    
    // Minimum (floating-point)
    fmin    v2.4s, v0.4s, v1.4s    // Element-wise min
    
    // Maximum (floating-point)
    fmax    v3.4s, v0.4s, v1.4s    // Element-wise max
    
    // Integer min/max
    ldr     x0, =int_array1
    ldr     x1, =int_array2
    ld1     {v0.4s}, [x0]
    ld1     {v1.4s}, [x1]
    
    smin    v2.4s, v0.4s, v1.4s    // Signed min
    smax    v3.4s, v0.4s, v1.4s    // Signed max
    umin    v4.4s, v0.4s, v1.4s    // Unsigned min
    umax    v5.4s, v0.4s, v1.4s    // Unsigned max
    
    // ========================================================================
    // REDUCTION OPERATIONS
    // ========================================================================
    
    // Add across vector (sum all elements)
    ldr     x0, =float_array1
    ld1     {v0.4s}, [x0]
    faddp   v1.4s, v0.4s, v0.4s    // Pairwise add
    faddp   v1.4s, v1.4s, v1.4s    // Pairwise add again
    // v1[0] now contains sum of all elements
    
    // Alternative: use addv for integer
    ldr     x0, =int_array1
    ld1     {v0.4s}, [x0]
    addv    s1, v0.4s              // s1 = sum of v0 elements
    
    // ========================================================================
    // DUPLICATE/BROADCAST
    // ========================================================================
    
    // Duplicate scalar to all lanes
    fmov    s0, #5.0               // Set scalar
    dup     v1.4s, v0.s[0]         // Broadcast to all 4 lanes
    // v1 = [5.0, 5.0, 5.0, 5.0]
    
    // Duplicate from general register
    mov     w0, #42
    dup     v2.4s, w0              // v2 = [42, 42, 42, 42]
    
    // ========================================================================
    // LANE OPERATIONS
    // ========================================================================
    
    // Extract element from vector
    ldr     x0, =float_array1
    ld1     {v0.4s}, [x0]
    mov     w1, v0.s[2]            // Extract 3rd element
    
    // Insert element into vector
    mov     w2, #100
    mov     v0.s[1], w2            // Insert into 2nd element
    
    // ========================================================================
    // ZIP/UNZIP (Interleave)
    // ========================================================================
    
    ldr     x0, =float_array1
    ldr     x1, =float_array2
    ld1     {v0.4s}, [x0]          // [1, 2, 3, 4]
    ld1     {v1.4s}, [x1]          // [5, 6, 7, 8]
    
    // Zip (interleave)
    zip1    v2.4s, v0.4s, v1.4s    // [1, 5, 2, 6]
    zip2    v3.4s, v0.4s, v1.4s    // [3, 7, 4, 8]
    
    // Unzip (de-interleave)
    uzp1    v4.4s, v2.4s, v3.4s    // Extract even elements
    uzp2    v5.4s, v2.4s, v3.4s    // Extract odd elements
    
    // ========================================================================
    // TRANSPOSE (4x4 matrix)
    // ========================================================================
    
    // Load 4 vectors representing rows
    // Transpose using zip operations
    // (conceptual - would need proper data setup)
    
    // ========================================================================
    // CONVERSION OPERATIONS
    // ========================================================================
    
    // Convert integer to float
    ldr     x0, =int_array1
    ld1     {v0.4s}, [x0]
    scvtf   v1.4s, v0.4s           // Signed int to float
    
    // Convert float to integer
    ldr     x0, =float_array1
    ld1     {v0.4s}, [x0]
    fcvtzs  v1.4s, v0.4s           // Float to signed int (truncate)
    fcvtns  v2.4s, v0.4s           // Float to signed int (nearest)
    
    // ========================================================================
    // ADVANCED MATH
    // ========================================================================
    
    // Square root
    ldr     x0, =float_array1
    ld1     {v0.4s}, [x0]
    fsqrt   v1.4s, v0.4s           // Square root of each element
    
    // Reciprocal estimate (fast approximation)
    frecpe  v2.4s, v0.4s           // v2 ≈ 1.0 / v0
    
    // Reciprocal square root estimate
    frsqrte v3.4s, v0.4s           // v3 ≈ 1.0 / sqrt(v0)
    
    // Absolute value
    fabs    v4.4s, v0.4s           // Absolute value
    
    // Negate
    fneg    v5.4s, v0.4s           // Negate
    
    // ========================================================================
    // SHIFT OPERATIONS (Integer Vectors)
    // ========================================================================
    
    ldr     x0, =int_array1
    ld1     {v0.4s}, [x0]
    
    // Shift left
    shl     v1.4s, v0.4s, #2       // Each element << 2
    
    // Shift right logical
    ushr    v2.4s, v0.4s, #1       // Each element >> 1 (unsigned)
    
    // Shift right arithmetic
    sshr    v3.4s, v0.4s, #1       // Each element >> 1 (signed)
    
    // ========================================================================
    // PRACTICAL EXAMPLE: Vector Addition Function
    // ========================================================================
    
    ldr     x0, =float_array1      // Source 1
    ldr     x1, =float_array2      // Source 2
    ldr     x2, =result_array      // Destination
    mov     x3, #4                 // Count (4 floats)
    bl      vector_add_neon
    
    // ========================================================================
    // PRACTICAL EXAMPLE: Dot Product
    // ========================================================================
    
    ldr     x0, =float_array1
    ldr     x1, =float_array2
    mov     x2, #4
    bl      dot_product_neon
    // Result in s0
    
    // ========================================================================
    // EXIT
    // ========================================================================
    
    mov     x8, #93
    mov     x0, #0
    svc     #0

// ============================================================================
// FUNCTION: vector_add_neon
// Description: Add two float vectors using NEON
// Arguments: X0 = array1, X1 = array2, X2 = result, X3 = count
// ============================================================================
vector_add_neon:
    // Process 4 floats at a time
.Lvec_add_loop:
    cmp     x3, #4
    b.lt    .Lvec_add_done
    
    ld1     {v0.4s}, [x0], #16     // Load 4 floats, advance pointer
    ld1     {v1.4s}, [x1], #16
    fadd    v2.4s, v0.4s, v1.4s    // Add vectors
    st1     {v2.4s}, [x2], #16     // Store result, advance pointer
    
    sub     x3, x3, #4             // Decrement count
    b       .Lvec_add_loop
    
.Lvec_add_done:
    // Handle remaining elements (if count not multiple of 4)
    // ... scalar code ...
    
    ret

// ============================================================================
// FUNCTION: dot_product_neon
// Description: Calculate dot product of two float vectors
// Arguments: X0 = array1, X1 = array2, X2 = count
// Returns: S0 = dot product
// ============================================================================
dot_product_neon:
    fmov    s0, wzr                // Accumulator = 0
    
    // Process 4 floats at a time
.Ldot_loop:
    cmp     x2, #4
    b.lt    .Ldot_done
    
    ld1     {v1.4s}, [x0], #16     // Load 4 floats from array1
    ld1     {v2.4s}, [x1], #16     // Load 4 floats from array2
    fmul    v3.4s, v1.4s, v2.4s    // Multiply
    faddp   v3.4s, v3.4s, v3.4s    // Pairwise add
    faddp   v3.4s, v3.4s, v3.4s    // Pairwise add again
    fadd    s0, s0, s3             // Accumulate
    
    sub     x2, x2, #4
    b       .Ldot_loop
    
.Ldot_done:
    ret

// ============================================================================
// NOTES: NEON/SIMD Programming
// ============================================================================
//
// Vector Register Notation:
//   v0.4s  = 4 single-precision floats (32-bit each)
//   v0.2d  = 2 double-precision floats (64-bit each)
//   v0.4h  = 4 half-precision floats (16-bit each)
//   v0.16b = 16 bytes (8-bit each)
//   v0.8b  = 8 bytes
//   v0.8h  = 8 halfwords (16-bit each)
//   v0.4h  = 4 halfwords
//   v0.2s  = 2 words (32-bit each)
//   v0.1d  = 1 doubleword (64-bit)
//
// Common Instructions:
//   Arithmetic: fadd, fsub, fmul, fdiv, add, sub, mul
//   MAC: fmla, fmls, mla, mls
//   Comparison: fcmeq, fcmgt, fcmge, cmeq, cmgt, cmge
//   Min/Max: fmin, fmax, smin, smax, umin, umax
//   Reduction: faddp, addv
//   Conversion: scvtf, ucvtf, fcvtzs, fcvtzu
//   Math: fsqrt, fabs, fneg, frecpe, frsqrte
//   Logical: and, orr, eor, bic, mvn
//   Shuffle: dup, zip1, zip2, uzp1, uzp2
//
// Performance Tips:
//   - Process 4 floats or 2 doubles at once
//   - Keep data 16-byte aligned
//   - Use load/store with post-increment
//   - Avoid lane extractions in hot loops
//   - Use reduction operations efficiently
//
// Speedup:
//   - 4x for single-precision operations
//   - 2x for double-precision operations
//   - More with careful algorithm design
//
// ============================================================================

