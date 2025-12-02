; ============================================================================
; File: 04_functions_and_stack.asm
; Description: Demonstrates function calls, stack operations, and calling conventions
; Topics: Stack, function prologue/epilogue, calling convention, local variables
; Assembler: NASM
; Build: nasm -f elf64 04_functions_and_stack.asm && ld -o 04_functions_and_stack 04_functions_and_stack.o
; ============================================================================

global _start

section .data
    result_msg: db "Result: ", 0
    newline:    db 0x0a

section .bss
    digit_buffer: resb 20       ; Buffer for number to string conversion

section .text

_start:
    ; ========================================================================
    ; STACK BASICS
    ; ========================================================================
    
    ; The stack grows DOWNWARD (from high addresses to low addresses)
    ; RSP (Stack Pointer) points to the TOP of the stack (lowest address in use)
    ; RBP (Base Pointer) typically points to the base of current stack frame
    
    ; PUSH - Decrements RSP by 8, then stores value
    ; POP  - Loads value, then increments RSP by 8
    
    mov     rax, 0x1234567890ABCDEF
    push    rax                 ; RSP -= 8, [RSP] = RAX
    
    mov     rax, 0              ; Clear RAX
    pop     rbx                 ; RBX = [RSP], RSP += 8
                                ; RBX now contains 0x1234567890ABCDEF
    
    ; Pushing/popping multiple registers
    push    rax
    push    rbx
    push    rcx
    
    ; Restore in reverse order
    pop     rcx
    pop     rbx
    pop     rax
    
    ; ========================================================================
    ; CALLING CONVENTION: System V AMD64 ABI (Linux, macOS, BSD)
    ; ========================================================================
    
    ; Function Arguments (integers/pointers):
    ;   1st: RDI
    ;   2nd: RSI
    ;   3rd: RDX
    ;   4th: RCX
    ;   5th: R8
    ;   6th: R9
    ;   7th+: Stack (right to left)
    ;
    ; Return value: RAX (RDX:RAX for 128-bit)
    ;
    ; Caller-saved (volatile): RAX, RCX, RDX, RSI, RDI, R8-R11
    ; Callee-saved (preserved): RBX, RBP, R12-R15
    ; Stack pointer: RSP (must be preserved)
    ; Stack alignment: 16-byte before CALL instruction
    
    ; ========================================================================
    ; SIMPLE FUNCTION CALL (No local variables)
    ; ========================================================================
    
    ; Call add_numbers(5, 10)
    mov     rdi, 5              ; First argument
    mov     rsi, 10             ; Second argument
    call    add_numbers         ; Call function
    ; RAX now contains 15 (return value)
    mov     r12, rax            ; Save result
    
    ; ========================================================================
    ; FUNCTION WITH MULTIPLE ARGUMENTS
    ; ========================================================================
    
    ; Call sum_six(1, 2, 3, 4, 5, 6)
    mov     rdi, 1              ; 1st argument
    mov     rsi, 2              ; 2nd argument
    mov     rdx, 3              ; 3rd argument
    mov     rcx, 4              ; 4th argument
    mov     r8, 5               ; 5th argument
    mov     r9, 6               ; 6th argument
    call    sum_six
    ; RAX = 21
    mov     r13, rax
    
    ; ========================================================================
    ; FUNCTION WITH STACK ARGUMENTS (More than 6 args)
    ; ========================================================================
    
    ; Call sum_eight(1, 2, 3, 4, 5, 6, 7, 8)
    ; Arguments 7 and 8 go on stack
    
    ; Stack must be 16-byte aligned before CALL
    ; After CALL, return address is pushed (8 bytes), misaligning stack
    ; So we need to ensure proper alignment
    
    ; Push arguments 8 and 7 (right to left)
    push    8                   ; 8th argument
    push    7                   ; 7th argument
    
    ; Set register arguments
    mov     rdi, 1
    mov     rsi, 2
    mov     rdx, 3
    mov     rcx, 4
    mov     r8, 5
    mov     r9, 6
    
    call    sum_eight
    add     rsp, 16             ; Clean up stack (2 args * 8 bytes)
    ; RAX = 36
    mov     r14, rax
    
    ; ========================================================================
    ; RECURSIVE FUNCTION EXAMPLE
    ; ========================================================================
    
    ; Calculate factorial(5)
    mov     rdi, 5
    call    factorial
    ; RAX = 120
    mov     r15, rax
    
    ; ========================================================================
    ; DEMONSTRATION: Print result
    ; ========================================================================
    
    mov     rdi, r15            ; Print factorial result
    call    print_number
    
    ; Exit
    mov     rax, 60
    xor     rdi, rdi
    syscall

; ============================================================================
; FUNCTION: add_numbers
; Description: Adds two numbers
; Arguments: RDI = first number, RSI = second number
; Returns: RAX = sum
; ============================================================================
add_numbers:
    ; No prologue needed - no local variables or saved registers
    
    mov     rax, rdi            ; RAX = first argument
    add     rax, rsi            ; RAX += second argument
    
    ret                         ; Return to caller

; ============================================================================
; FUNCTION: sum_six
; Description: Sums six arguments
; Arguments: RDI, RSI, RDX, RCX, R8, R9
; Returns: RAX = sum
; ============================================================================
sum_six:
    ; Simple function - no need to save registers
    
    mov     rax, rdi
    add     rax, rsi
    add     rax, rdx
    add     rax, rcx
    add     rax, r8
    add     rax, r9
    
    ret

; ============================================================================
; FUNCTION: sum_eight
; Description: Sums eight arguments (demonstrates stack parameters)
; Arguments: RDI, RSI, RDX, RCX, R8, R9, [RSP+8], [RSP+16]
; Returns: RAX = sum
; Note: Stack layout after CALL:
;   [RSP+0]  = Return address
;   [RSP+8]  = 7th argument
;   [RSP+16] = 8th argument
; ============================================================================
sum_eight:
    ; Sum register arguments
    mov     rax, rdi
    add     rax, rsi
    add     rax, rdx
    add     rax, rcx
    add     rax, r8
    add     rax, r9
    
    ; Add stack arguments
    add     rax, [rsp + 8]      ; 7th argument
    add     rax, [rsp + 16]     ; 8th argument
    
    ret

; ============================================================================
; FUNCTION: factorial (Recursive)
; Description: Calculates factorial recursively
; Arguments: RDI = n
; Returns: RAX = n!
; Stack frame demonstration with local variables and saved registers
; ============================================================================
factorial:
    ; Function Prologue
    push    rbp                 ; Save old base pointer
    mov     rbp, rsp            ; Set new base pointer
    
    ; Save callee-saved register we'll use
    push    rbx                 ; We'll use RBX
    
    ; Allocate space for local variables (if needed)
    ; sub   rsp, 16             ; Example: allocate 16 bytes
    
    ; Base case: if n <= 1, return 1
    cmp     rdi, 1
    jg      factorial_recursive ; If n > 1, do recursion
    
    ; Base case: return 1
    mov     rax, 1
    jmp     factorial_return
    
factorial_recursive:
    ; Recursive case: n * factorial(n-1)
    
    mov     rbx, rdi            ; Save n in RBX (callee-saved)
    
    dec     rdi                 ; n - 1
    call    factorial           ; factorial(n-1), result in RAX
    
    imul    rax, rbx            ; RAX = RAX * n
    
factorial_return:
    ; Function Epilogue
    pop     rbx                 ; Restore RBX
    mov     rsp, rbp            ; Deallocate locals (restore stack pointer)
    pop     rbp                 ; Restore old base pointer
    ret

; ============================================================================
; FUNCTION: multiply
; Description: Demonstrates typical function with prologue/epilogue
; Arguments: RDI = a, RSI = b
; Returns: RAX = a * b
; ============================================================================
multiply:
    ; === PROLOGUE ===
    push    rbp                 ; Save old frame pointer
    mov     rbp, rsp            ; Set new frame pointer
    
    ; Save any callee-saved registers we'll modify
    ; push  rbx                 ; If we used RBX
    
    ; Allocate space for local variables
    sub     rsp, 16             ; Allocate 16 bytes (maintains 16-byte alignment)
    
    ; === FUNCTION BODY ===
    
    ; Local variables can be accessed via RBP:
    ; [rbp - 8]  = local variable 1
    ; [rbp - 16] = local variable 2
    
    mov     [rbp - 8], rdi      ; Store first argument as local
    mov     [rbp - 16], rsi     ; Store second argument as local
    
    ; Do computation
    mov     rax, [rbp - 8]
    imul    rax, [rbp - 16]
    
    ; === EPILOGUE ===
    
    mov     rsp, rbp            ; Deallocate locals
    pop     rbp                 ; Restore old frame pointer
    ret

; ============================================================================
; FUNCTION: complex_function
; Description: Demonstrates complete function structure
; ============================================================================
complex_function:
    ; === PROLOGUE ===
    push    rbp
    mov     rbp, rsp
    
    ; Save callee-saved registers
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    
    ; Allocate local variables (32 bytes, for example)
    sub     rsp, 32
    
    ; === FUNCTION BODY ===
    
    ; Local variables at:
    ; [rbp - 8]  through [rbp - 32]
    
    ; Use saved registers freely
    mov     rbx, 100
    mov     r12, 200
    ; ... function work ...
    
    ; Return value in RAX
    mov     rax, rbx
    add     rax, r12
    
    ; === EPILOGUE ===
    
    ; Deallocate locals
    add     rsp, 32             ; Or: mov rsp, rbp
    
    ; Restore callee-saved registers (reverse order)
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    
    pop     rbp
    ret

; ============================================================================
; FUNCTION: print_number
; Description: Prints a number to stdout
; Arguments: RDI = number to print
; ============================================================================
print_number:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    
    mov     rax, rdi            ; Number to convert
    lea     rbx, [digit_buffer + 19]  ; Point to end of buffer
    mov     byte [rbx], 0x0a    ; Newline
    dec     rbx
    
    ; Handle zero specially
    test    rax, rax
    jnz     .convert_loop
    mov     byte [rbx], '0'
    dec     rbx
    jmp     .print
    
.convert_loop:
    test    rax, rax
    jz      .print
    
    xor     rdx, rdx            ; Clear RDX for division
    mov     r12, 10
    div     r12                 ; RAX = quotient, RDX = remainder
    
    add     dl, '0'             ; Convert digit to ASCII
    mov     [rbx], dl
    dec     rbx
    
    jmp     .convert_loop
    
.print:
    inc     rbx                 ; Adjust pointer
    
    ; Calculate length
    lea     r12, [digit_buffer + 20]
    sub     r12, rbx
    
    ; Write to stdout
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    mov     rsi, rbx            ; buffer
    mov     rdx, r12            ; length
    syscall
    
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ============================================================================
; STACK FRAME VISUALIZATION
; ============================================================================
;
; After function prologue (push rbp; mov rbp, rsp; sub rsp, N):
;
;   High Addresses
;   ┌──────────────────────┐
;   │  Caller's Stack      │
;   ├──────────────────────┤
;   │  Argument 7 (if any) │  [rbp + 24]
;   ├──────────────────────┤
;   │  Argument 6 (if any) │  [rbp + 16]
;   ├──────────────────────┤
;   │  Return Address      │  [rbp + 8]  (pushed by CALL)
;   ├──────────────────────┤
;   │  Saved RBP           │  [rbp]      (pushed by prologue)
;   ├──────────────────────┤ ← RBP points here
;   │  Local Variable 1    │  [rbp - 8]
;   ├──────────────────────┤
;   │  Local Variable 2    │  [rbp - 16]
;   ├──────────────────────┤
;   │  Saved Registers     │  [rbp - 24] (if any)
;   ├──────────────────────┤
;   │  ...                 │
;   ├──────────────────────┤ ← RSP points here
;   │  (unused/growth)     │
;   └──────────────────────┘
;   Low Addresses
;
; ============================================================================
; CALLING CONVENTION SUMMARY
; ============================================================================
;
; System V AMD64 ABI (Linux, BSD, macOS):
; ┌─────────────────────────────────────────────────────────────┐
; │ Integer/Pointer Args: RDI, RSI, RDX, RCX, R8, R9           │
; │ Float Args: XMM0-XMM7                                       │
; │ Return: RAX (int), XMM0 (float)                            │
; │ Caller-saved: RAX, RCX, RDX, RSI, RDI, R8-R11              │
; │ Callee-saved: RBX, RBP, R12-R15                            │
; │ Stack alignment: 16-byte before CALL                        │
; └─────────────────────────────────────────────────────────────┘
;
; Microsoft x64 (Windows):
; ┌─────────────────────────────────────────────────────────────┐
; │ Integer/Pointer Args: RCX, RDX, R8, R9                     │
; │ Float Args: XMM0-XMM3                                       │
; │ Return: RAX (int), XMM0 (float)                            │
; │ Caller-saved: RAX, RCX, RDX, R8-R11                        │
; │ Callee-saved: RBX, RBP, RDI, RSI, R12-R15                  │
; │ Shadow space: 32 bytes (caller allocates for reg args)     │
; │ Stack alignment: 16-byte before CALL                        │
; └─────────────────────────────────────────────────────────────┘
;
; ============================================================================
; BEST PRACTICES
; ============================================================================
;
; 1. Always maintain 16-byte stack alignment before CALL
; 2. Save and restore callee-saved registers (RBX, RBP, R12-R15)
; 3. Use RBP as frame pointer for easier debugging
; 4. Clean up stack arguments after function returns (caller's job)
; 5. Prefer leaf functions (no calls) to avoid prologue/epilogue overhead
; 6. For simple functions, inline or use registers only
; 7. Comment function contracts (args, returns, modifies)
;
; ============================================================================

