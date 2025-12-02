; ============================================================================
; File: 08_simd_sse.asm
; Description: SIMD programming with SSE/AVX instructions
; Topics: XMM registers, packed operations, vectorization
; Assembler: NASM
; Build: nasm -f elf64 08_simd_sse.asm && ld -o 08_simd_sse 08_simd_sse.o
; Note: Requires CPU with SSE/AVX support
; ============================================================================

global _start

section .data
    ; Aligned data (16-byte alignment required for aligned loads/stores)
    align 16
    float_array1:   dd 1.0, 2.0, 3.0, 4.0      ; 4 floats (128 bits)
    align 16
    float_array2:   dd 5.0, 6.0, 7.0, 8.0
    
    align 16
    double_array1:  dq 1.5, 2.5                ; 2 doubles (128 bits)
    align 16
    double_array2:  dq 3.5, 4.5
    
    align 16
    int_array1:     dd 1, 2, 3, 4              ; 4 integers
    align 16
    int_array2:     dd 10, 20, 30, 40
    
    ; Scalar values
    scalar_float:   dd 10.0
    scalar_double:  dq 100.0
    
    ; Messages
    msg:            db "SIMD Operations Complete", 0x0a
    msg_len:        equ $ - msg

section .bss
    align 16
    result_array:   resd 4                     ; Result array
    align 16
    temp_array:     resd 4

section .text

_start:
    ; ========================================================================
    ; XMM REGISTER BASICS
    ; ========================================================================
    
    ; x86_64 has 16 XMM registers: XMM0-XMM15
    ; Each XMM register is 128 bits (16 bytes)
    ; Can hold:
    ;   - 4 single-precision floats (32-bit each)
    ;   - 2 double-precision doubles (64-bit each)
    ;   - 16 bytes, 8 words, 4 dwords, 2 qwords (integer)
    
    ; ========================================================================
    ; LOADING DATA INTO XMM REGISTERS
    ; ========================================================================
    
    ; Aligned load (faster, requires 16-byte alignment)
    movaps  xmm0, [float_array1]       ; Load 4 floats into XMM0
    
    ; Unaligned load (slower, but works with any alignment)
    movups  xmm1, [float_array2]       ; Load 4 floats into XMM1
    
    ; For doubles
    movapd  xmm2, [double_array1]      ; Load 2 doubles (aligned)
    movupd  xmm3, [double_array2]      ; Load 2 doubles (unaligned)
    
    ; Load scalar (single float)
    movss   xmm4, [scalar_float]       ; Load one float to lowest 32 bits
    
    ; Load scalar double
    movsd   xmm5, [scalar_double]      ; Load one double to lowest 64 bits
    
    ; ========================================================================
    ; STORING DATA FROM XMM REGISTERS
    ; ========================================================================
    
    ; Aligned store
    movaps  [result_array], xmm0       ; Store XMM0 to memory
    
    ; Unaligned store
    movups  [temp_array], xmm1
    
    ; Store scalar
    movss   [result_array], xmm4       ; Store one float
    movsd   [result_array], xmm5       ; Store one double
    
    ; ========================================================================
    ; ARITHMETIC OPERATIONS (Packed Single-Precision)
    ; ========================================================================
    
    ; Packed addition (4 floats at once)
    movaps  xmm0, [float_array1]       ; XMM0 = [1.0, 2.0, 3.0, 4.0]
    movaps  xmm1, [float_array2]       ; XMM1 = [5.0, 6.0, 7.0, 8.0]
    addps   xmm0, xmm1                 ; XMM0 = [6.0, 8.0, 10.0, 12.0]
    
    ; Packed subtraction
    movaps  xmm0, [float_array1]
    movaps  xmm1, [float_array2]
    subps   xmm0, xmm1                 ; XMM0 = [-4.0, -4.0, -4.0, -4.0]
    
    ; Packed multiplication
    movaps  xmm0, [float_array1]
    movaps  xmm1, [float_array2]
    mulps   xmm0, xmm1                 ; XMM0 = [5.0, 12.0, 21.0, 32.0]
    
    ; Packed division
    movaps  xmm0, [float_array1]
    movaps  xmm1, [float_array2]
    divps   xmm0, xmm1                 ; XMM0 = [0.2, 0.333..., 0.428..., 0.5]
    
    ; ========================================================================
    ; ARITHMETIC OPERATIONS (Scalar Single-Precision)
    ; ========================================================================
    
    ; Scalar operations (only on lowest element)
    movaps  xmm0, [float_array1]
    movaps  xmm1, [float_array2]
    addss   xmm0, xmm1                 ; XMM0[0] += XMM1[0], others unchanged
    
    ; ========================================================================
    ; ARITHMETIC OPERATIONS (Packed Double-Precision)
    ; ========================================================================
    
    ; Packed double operations (2 doubles at once)
    movapd  xmm0, [double_array1]      ; XMM0 = [1.5, 2.5]
    movapd  xmm1, [double_array2]      ; XMM1 = [3.5, 4.5]
    addpd   xmm0, xmm1                 ; XMM0 = [5.0, 7.0]
    
    subpd   xmm0, xmm1                 ; Subtraction
    mulpd   xmm0, xmm1                 ; Multiplication
    divpd   xmm0, xmm1                 ; Division
    
    ; Scalar double operations
    addsd   xmm0, xmm1                 ; Add only lowest double
    
    ; ========================================================================
    ; ADVANCED MATH OPERATIONS
    ; ========================================================================
    
    ; Square root (packed)
    movaps  xmm0, [float_array1]
    sqrtps  xmm0, xmm0                 ; Square root of each element
    
    ; Square root (scalar)
    sqrtss  xmm0, xmm0                 ; Square root of lowest element
    
    ; Reciprocal (approximate, faster than division)
    movaps  xmm0, [float_array1]
    rcpps   xmm0, xmm0                 ; XMM0 = 1.0 / XMM0 (approximate)
    
    ; Reciprocal square root (approximate)
    rsqrtps xmm0, xmm0                 ; XMM0 = 1.0 / sqrt(XMM0)
    
    ; Min/Max
    movaps  xmm0, [float_array1]
    movaps  xmm1, [float_array2]
    minps   xmm0, xmm1                 ; XMM0 = min of each pair
    maxps   xmm0, xmm1                 ; XMM0 = max of each pair
    
    ; ========================================================================
    ; LOGICAL OPERATIONS
    ; ========================================================================
    
    ; AND, OR, XOR (bitwise on all 128 bits)
    movaps  xmm0, [float_array1]
    movaps  xmm1, [float_array2]
    
    andps   xmm0, xmm1                 ; Bitwise AND
    orps    xmm0, xmm1                 ; Bitwise OR
    xorps   xmm0, xmm1                 ; Bitwise XOR
    andnps  xmm0, xmm1                 ; AND NOT (NOT xmm0 AND xmm1)
    
    ; Common use: Clear register (faster than loading zero)
    xorps   xmm0, xmm0                 ; XMM0 = 0.0 (all elements)
    
    ; ========================================================================
    ; COMPARISON OPERATIONS
    ; ========================================================================
    
    ; Compare packed floats (result is mask: all 1s or all 0s per element)
    movaps  xmm0, [float_array1]
    movaps  xmm1, [float_array2]
    
    cmpeqps  xmm0, xmm1                ; XMM0 = (XMM0 == XMM1) ? 0xFFFFFFFF : 0
    cmpltps  xmm0, xmm1                ; XMM0 = (XMM0 < XMM1) ? 0xFFFFFFFF : 0
    cmpleps  xmm0, xmm1                ; Less or equal
    cmpneqps xmm0, xmm1                ; Not equal
    
    ; Move mask to integer register (extract comparison results)
    movmskps eax, xmm0                 ; EAX bits = sign bits of XMM0 elements
    
    ; ========================================================================
    ; DATA MOVEMENT AND SHUFFLING
    ; ========================================================================
    
    ; Shuffle (rearrange elements)
    movaps  xmm0, [float_array1]       ; [1.0, 2.0, 3.0, 4.0]
    shufps  xmm0, xmm0, 0x1B           ; Reverse order
    ; Shuffle immediate: bits [1:0]=elem3, [3:2]=elem2, [5:4]=elem1, [7:6]=elem0
    
    ; Unpack (interleave)
    movaps  xmm0, [float_array1]       ; [1.0, 2.0, 3.0, 4.0]
    movaps  xmm1, [float_array2]       ; [5.0, 6.0, 7.0, 8.0]
    unpcklps xmm0, xmm1                ; Unpack low: [1.0, 5.0, 2.0, 6.0]
    unpckhps xmm0, xmm1                ; Unpack high: [3.0, 7.0, 4.0, 8.0]
    
    ; Move high/low parts
    movhlps xmm0, xmm1                 ; XMM0[low] = XMM1[high]
    movlhps xmm0, xmm1                 ; XMM0[high] = XMM1[low]
    
    ; ========================================================================
    ; INTEGER OPERATIONS (SIMD)
    ; ========================================================================
    
    ; Load integer arrays
    movdqa  xmm0, [int_array1]         ; Aligned move (DQ = double quadword)
    movdqu  xmm1, [int_array2]         ; Unaligned move
    
    ; Packed integer addition (4 dwords)
    paddd   xmm0, xmm1                 ; XMM0 += XMM1 (each dword)
    
    ; Other packed integer operations
    psubd   xmm0, xmm1                 ; Subtraction
    pmulld  xmm0, xmm1                 ; Multiplication (SSE4.1)
    
    ; Packed byte/word/dword operations
    paddb   xmm0, xmm1                 ; Add 16 bytes
    paddw   xmm0, xmm1                 ; Add 8 words
    paddd   xmm0, xmm1                 ; Add 4 dwords
    paddq   xmm0, xmm1                 ; Add 2 qwords
    
    ; Shift operations (integer SIMD)
    pslld   xmm0, 2                    ; Shift left logical (each dword by 2)
    psrld   xmm0, 2                    ; Shift right logical
    psrad   xmm0, 2                    ; Shift right arithmetic (sign extend)
    
    ; ========================================================================
    ; CONVERSION OPERATIONS
    ; ========================================================================
    
    ; Convert packed integers to floats
    movdqa  xmm0, [int_array1]         ; Load integers
    cvtdq2ps xmm0, xmm0                ; Convert to floats
    
    ; Convert packed floats to integers (truncate)
    movaps  xmm0, [float_array1]
    cvttps2dq xmm0, xmm0               ; Truncate to integers
    
    ; Convert with rounding
    cvtps2dq xmm0, xmm0                ; Round to nearest integer
    
    ; Convert single to double
    cvtps2pd xmm0, xmm0                ; Convert 2 floats to 2 doubles
    
    ; Convert double to single
    cvtpd2ps xmm0, xmm0                ; Convert 2 doubles to 2 floats
    
    ; ========================================================================
    ; PRACTICAL EXAMPLE: Vector Addition
    ; ========================================================================
    
    lea     rdi, [float_array1]
    lea     rsi, [float_array2]
    lea     rdx, [result_array]
    mov     rcx, 4                     ; 4 elements
    call    vector_add_simd
    
    ; ========================================================================
    ; PRACTICAL EXAMPLE: Dot Product
    ; ========================================================================
    
    lea     rdi, [float_array1]
    lea     rsi, [float_array2]
    mov     rcx, 4
    call    dot_product_simd
    ; Result in XMM0
    
    ; ========================================================================
    ; HORIZONTAL OPERATIONS
    ; ========================================================================
    
    ; Horizontal add (sum adjacent pairs)
    movaps  xmm0, [float_array1]       ; [1.0, 2.0, 3.0, 4.0]
    movaps  xmm1, [float_array2]       ; [5.0, 6.0, 7.0, 8.0]
    haddps  xmm0, xmm1                 ; [3.0, 7.0, 11.0, 15.0]
    
    ; Horizontal subtract
    hsubps  xmm0, xmm1                 ; Subtract adjacent pairs
    
    ; ========================================================================
    ; EXIT
    ; ========================================================================
    
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg
    mov     rdx, msg_len
    syscall
    
    mov     rax, 60
    xor     rdi, rdi
    syscall

; ============================================================================
; FUNCTION: vector_add_simd
; Description: Add two float vectors using SIMD
; Arguments: RDI = array1, RSI = array2, RDX = result, RCX = count
; Note: Count should be multiple of 4 for efficiency
; ============================================================================
vector_add_simd:
    push    rbp
    mov     rbp, rsp
    
    ; Process 4 floats at a time
.loop:
    cmp     rcx, 0
    jle     .done
    
    movaps  xmm0, [rdi]                ; Load 4 floats from array1
    movaps  xmm1, [rsi]                ; Load 4 floats from array2
    addps   xmm0, xmm1                 ; Add vectors
    movaps  [rdx], xmm0                ; Store result
    
    add     rdi, 16                    ; Advance pointers (4 floats * 4 bytes)
    add     rsi, 16
    add     rdx, 16
    sub     rcx, 4                     ; Processed 4 elements
    
    jmp     .loop
    
.done:
    pop     rbp
    ret

; ============================================================================
; FUNCTION: dot_product_simd
; Description: Calculate dot product of two float vectors
; Arguments: RDI = array1, RSI = array2, RCX = count
; Returns: XMM0 = dot product result (scalar)
; ============================================================================
dot_product_simd:
    push    rbp
    mov     rbp, rsp
    
    xorps   xmm2, xmm2                 ; Accumulator = 0
    
    ; Process 4 floats at a time
.loop:
    cmp     rcx, 0
    jle     .reduce
    
    movaps  xmm0, [rdi]                ; Load 4 floats from array1
    movaps  xmm1, [rsi]                ; Load 4 floats from array2
    mulps   xmm0, xmm1                 ; Multiply vectors
    addps   xmm2, xmm0                 ; Accumulate
    
    add     rdi, 16
    add     rsi, 16
    sub     rcx, 4
    
    jmp     .loop
    
.reduce:
    ; Horizontal sum: reduce XMM2 to scalar
    ; XMM2 = [a, b, c, d]
    movaps  xmm0, xmm2
    shufps  xmm0, xmm0, 0x4E           ; Swap halves: [c, d, a, b]
    addps   xmm2, xmm0                 ; [a+c, b+d, c+a, d+b]
    
    movaps  xmm0, xmm2
    shufps  xmm0, xmm0, 0xB1           ; Swap pairs: [b+d, a+c, d+b, c+a]
    addps   xmm2, xmm0                 ; [sum, sum, sum, sum]
    
    movaps  xmm0, xmm2                 ; Result in XMM0
    
    pop     rbp
    ret

; ============================================================================
; FUNCTION: scalar_multiply_simd
; Description: Multiply vector by scalar
; Arguments: RDI = array, RCX = count, XMM0 = scalar
; ============================================================================
scalar_multiply_simd:
    push    rbp
    mov     rbp, rsp
    
    ; Broadcast scalar to all 4 elements
    shufps  xmm0, xmm0, 0              ; XMM0 = [scalar, scalar, scalar, scalar]
    
.loop:
    cmp     rcx, 0
    jle     .done
    
    movaps  xmm1, [rdi]                ; Load 4 floats
    mulps   xmm1, xmm0                 ; Multiply by scalar
    movaps  [rdi], xmm1                ; Store back
    
    add     rdi, 16
    sub     rcx, 4
    jmp     .loop
    
.done:
    pop     rbp
    ret

; ============================================================================
; NOTES: SIMD/SSE Programming
; ============================================================================
;
; XMM Registers (SSE):
;   - 16 registers: XMM0-XMM15 (x86_64)
;   - 128 bits each
;   - Can hold: 4 floats, 2 doubles, or integers
;
; Instruction Naming Convention:
;   - PS = Packed Single-precision (4 floats)
;   - PD = Packed Double-precision (2 doubles)
;   - SS = Scalar Single-precision (1 float, lowest 32 bits)
;   - SD = Scalar Double-precision (1 double, lowest 64 bits)
;
; Common Operations:
;   movaps/movups - Move aligned/unaligned packed single
;   movapd/movupd - Move aligned/unaligned packed double
;   addps/subps/mulps/divps - Packed arithmetic
;   sqrtps, rcpps, rsqrtps - Math operations
;   minps, maxps - Min/max
;   andps, orps, xorps - Logical
;   cmpps - Comparison
;
; Performance Tips:
;   - Keep data 16-byte aligned for best performance
;   - Use aligned loads/stores (movaps) when possible
;   - Process multiple elements per iteration
;   - Avoid frequent scalar-vector conversions
;   - Use horizontal operations sparingly (slower)
;
; Speedup:
;   - 4x for single-precision operations
;   - 2x for double-precision operations
;   - More with AVX (256-bit) and AVX-512 (512-bit)
;
; ============================================================================

