; ============================================================================
; File: 03_control_flow.asm
; Description: Demonstrates control flow: jumps, loops, and conditional execution
; Topics: Jumps, conditional jumps, loops, flags register, comparisons
; Assembler: NASM
; Build: nasm -f elf64 03_control_flow.asm && ld -o 03_control_flow 03_control_flow.o
; ============================================================================

global _start

section .data
    msg1:       db "Loop iteration", 0x0a
    msg1_len:   equ $ - msg1
    msg2:       db "Done!", 0x0a
    msg2_len:   equ $ - msg2

section .text

_start:
    ; ========================================================================
    ; UNCONDITIONAL JUMP
    ; ========================================================================
    
    ; JMP - Jump to a label (always)
    jmp     start_demo          ; Jump to start_demo label
    
    ; This code will never execute
    mov     rax, 999
    
start_demo:
    mov     rax, 1              ; This executes instead
    
    ; ========================================================================
    ; COMPARISON AND FLAGS
    ; ========================================================================
    
    ; CMP instruction subtracts operands and sets flags (doesn't store result)
    ; Flags affected: ZF (zero), SF (sign), CF (carry), OF (overflow), PF, AF
    
    mov     rax, 10
    mov     rbx, 20
    cmp     rax, rbx            ; Compare RAX with RBX (computes RAX - RBX)
                                ; Sets flags: ZF=0 (not equal), SF=1 (negative)
    
    ; TEST instruction performs AND and sets flags (doesn't store result)
    ; Commonly used to check if register is zero or test specific bits
    
    mov     rax, 0
    test    rax, rax            ; Test if RAX is zero
                                ; Sets ZF=1 if zero, clears it otherwise
    
    ; ========================================================================
    ; CONDITIONAL JUMPS (Signed Comparisons)
    ; ========================================================================
    
    ; Jump based on comparison results:
    ; JE/JZ   - Jump if Equal / Jump if Zero (ZF=1)
    ; JNE/JNZ - Jump if Not Equal / Jump if Not Zero (ZF=0)
    ; JG/JNLE - Jump if Greater (signed) / Jump if Not Less or Equal
    ; JGE/JNL - Jump if Greater or Equal (signed) / Jump if Not Less
    ; JL/JNGE - Jump if Less (signed) / Jump if Not Greater or Equal
    ; JLE/JNG - Jump if Less or Equal (signed) / Jump if Not Greater
    
    mov     rax, 10
    mov     rbx, 20
    cmp     rax, rbx
    je      equal_label         ; Jump if RAX == RBX (not taken)
    jne     not_equal_label     ; Jump if RAX != RBX (taken)
    
equal_label:
    ; Not executed in this case
    jmp     after_cond
    
not_equal_label:
    ; This code executes
    ; Continue...
    
after_cond:
    ; Greater than comparison
    mov     rax, 30
    mov     rbx, 20
    cmp     rax, rbx
    jg      greater_label       ; Jump if RAX > RBX (signed) - taken
    jmp     after_greater
    
greater_label:
    ; This executes
    
after_greater:
    ; Less than comparison
    mov     rax, 10
    mov     rbx, 20
    cmp     rax, rbx
    jl      less_label          ; Jump if RAX < RBX (signed) - taken
    jmp     after_less
    
less_label:
    ; This executes
    
after_less:
    
    ; ========================================================================
    ; CONDITIONAL JUMPS (Unsigned Comparisons)
    ; ========================================================================
    
    ; For unsigned comparisons, use different mnemonics:
    ; JA/JNBE - Jump if Above (unsigned) / Jump if Not Below or Equal
    ; JAE/JNB - Jump if Above or Equal (unsigned) / Jump if Not Below
    ; JB/JNAE - Jump if Below (unsigned) / Jump if Not Above or Equal
    ; JBE/JNA - Jump if Below or Equal (unsigned) / Jump if Not Above
    
    mov     rax, 0xFFFFFFFFFFFFFFFF    ; -1 as signed, max as unsigned
    mov     rbx, 1
    cmp     rax, rbx
    jg      signed_greater      ; Not taken (signed: -1 < 1)
    ja      unsigned_greater    ; Taken (unsigned: max > 1)
    
signed_greater:
    ; Not executed
    jmp     after_unsigned
    
unsigned_greater:
    ; This executes
    
after_unsigned:
    
    ; ========================================================================
    ; OTHER CONDITIONAL JUMPS
    ; ========================================================================
    
    ; Jump based on specific flags:
    ; JC  - Jump if Carry (CF=1)
    ; JNC - Jump if Not Carry (CF=0)
    ; JO  - Jump if Overflow (OF=1)
    ; JNO - Jump if Not Overflow (OF=0)
    ; JS  - Jump if Sign (SF=1, negative)
    ; JNS - Jump if Not Sign (SF=0, positive)
    ; JP/JPE - Jump if Parity Even (PF=1)
    ; JNP/JPO - Jump if Parity Odd (PF=0)
    
    ; ========================================================================
    ; SIMPLE LOOP EXAMPLE
    ; ========================================================================
    
    ; Print message 5 times using conditional jump
    mov     rcx, 5              ; Loop counter
    
print_loop:
    ; Print message
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    mov     rsi, msg1           ; message
    mov     rdx, msg1_len       ; length
    syscall
    
    dec     rcx                 ; Decrement counter
    jnz     print_loop          ; Jump if not zero (repeat if RCX != 0)
    
    ; ========================================================================
    ; LOOP INSTRUCTION
    ; ========================================================================
    
    ; LOOP instruction: decrements RCX and jumps if RCX != 0
    ; Note: Generally slower than dec + jnz on modern CPUs
    
    mov     rcx, 3              ; Set counter
    
loop_example:
    ; Do something here
    ; ... code ...
    loop    loop_example        ; Decrement RCX and jump if RCX != 0
    
    ; ========================================================================
    ; FOR LOOP PATTERN (C-style)
    ; ========================================================================
    
    ; Equivalent to: for(int i = 0; i < 10; i++)
    
    xor     rcx, rcx            ; i = 0 (initialize)
    
for_loop:
    cmp     rcx, 10             ; Compare i with 10
    jge     for_done            ; Exit if i >= 10
    
    ; Loop body
    ; ... do work ...
    
    inc     rcx                 ; i++
    jmp     for_loop            ; Continue loop
    
for_done:
    
    ; ========================================================================
    ; WHILE LOOP PATTERN
    ; ========================================================================
    
    ; Equivalent to: while(rax < 100)
    
    mov     rax, 0
    
while_loop:
    cmp     rax, 100
    jge     while_done          ; Exit if RAX >= 100
    
    ; Loop body
    add     rax, 10             ; Increment by 10
    
    jmp     while_loop
    
while_done:
    
    ; ========================================================================
    ; DO-WHILE LOOP PATTERN
    ; ========================================================================
    
    ; Equivalent to: do { ... } while(rax < 50);
    
    mov     rax, 0
    
do_while_loop:
    ; Loop body executes at least once
    add     rax, 5
    
    cmp     rax, 50
    jl      do_while_loop       ; Continue if RAX < 50
    
    ; ========================================================================
    ; NESTED LOOPS
    ; ========================================================================
    
    ; Outer loop: i from 0 to 2
    ; Inner loop: j from 0 to 3
    
    xor     rbx, rbx            ; i = 0 (outer counter)
    
outer_loop:
    cmp     rbx, 3
    jge     outer_done
    
    xor     rcx, rcx            ; j = 0 (inner counter)
    
inner_loop:
    cmp     rcx, 4
    jge     inner_done
    
    ; Loop body: i and j are in RBX and RCX
    ; ... do work ...
    
    inc     rcx                 ; j++
    jmp     inner_loop
    
inner_done:
    inc     rbx                 ; i++
    jmp     outer_loop
    
outer_done:
    
    ; ========================================================================
    ; BREAK AND CONTINUE PATTERNS
    ; ========================================================================
    
    ; Loop with break (exit early)
    mov     rcx, 10
    
break_loop:
    cmp     rcx, 0
    jle     break_done
    
    ; Check break condition
    cmp     rcx, 5
    je      break_done          ; Break when RCX == 5
    
    dec     rcx
    jmp     break_loop
    
break_done:
    
    ; Loop with continue (skip to next iteration)
    mov     rcx, 10
    
continue_loop:
    cmp     rcx, 0
    jle     continue_done
    
    dec     rcx
    
    ; Check continue condition
    test    rcx, 1              ; Test if odd (bit 0 set)
    jz      continue_loop       ; Continue if even (skip rest)
    
    ; Process odd numbers only
    ; ... do work ...
    
    jmp     continue_loop
    
continue_done:
    
    ; ========================================================================
    ; SWITCH/CASE PATTERN (Jump Table)
    ; ========================================================================
    
    ; Equivalent to: switch(value) { case 0: ... case 1: ... }
    
    mov     rax, 1              ; Value to switch on (0-2)
    
    ; Bounds check
    cmp     rax, 2
    ja      switch_default      ; Jump to default if > 2
    
    ; Jump table approach
    ; Calculate jump: jump_table + rax * 8 (8 bytes per address)
    lea     rbx, [jump_table]
    mov     rax, [rbx + rax*8]  ; Load address from table
    jmp     rax                 ; Jump to the address
    
switch_case0:
    ; Case 0 code
    mov     rdx, 0
    jmp     switch_end
    
switch_case1:
    ; Case 1 code
    mov     rdx, 1
    jmp     switch_end
    
switch_case2:
    ; Case 2 code
    mov     rdx, 2
    jmp     switch_end
    
switch_default:
    ; Default case
    mov     rdx, -1
    
switch_end:
    
    ; ========================================================================
    ; CONDITIONAL EXECUTION WITHOUT BRANCHING
    ; ========================================================================
    
    ; Using CMOV (Conditional Move) - faster for simple conditions
    ; Avoids branch misprediction penalties
    
    mov     rax, 10
    mov     rbx, 20
    mov     rcx, 100            ; Value if true
    mov     rdx, 200            ; Value if false
    
    cmp     rax, rbx
    cmovl   rdx, rcx            ; Move RCX to RDX if RAX < RBX
                                ; RDX = 100 (since 10 < 20)
    
    ; Other CMOVcc instructions:
    ; CMOVE/CMOVZ   - Move if Equal/Zero
    ; CMOVNE/CMOVNZ - Move if Not Equal/Not Zero
    ; CMOVG/CMOVNLE - Move if Greater (signed)
    ; CMOVL/CMOVNGE - Move if Less (signed)
    ; CMOVA/CMOVNBE - Move if Above (unsigned)
    ; CMOVB/CMOVNAE - Move if Below (unsigned)
    
    ; ========================================================================
    ; SET BYTE ON CONDITION (SETcc)
    ; ========================================================================
    
    ; Set byte to 1 if condition true, 0 otherwise
    
    mov     rax, 10
    mov     rbx, 20
    cmp     rax, rbx
    setl    cl                  ; Set CL to 1 if RAX < RBX, else 0
                                ; CL = 1
    
    ; ========================================================================
    ; CALL AND RETURN (Function Calls)
    ; ========================================================================
    
    ; CALL pushes return address and jumps to function
    ; RET pops return address and jumps to it
    
    call    my_function         ; Call function
    ; Execution continues here after function returns
    
    jmp     after_function
    
my_function:
    ; Function body
    mov     rax, 42
    ret                         ; Return to caller
    
after_function:
    
    ; ========================================================================
    ; FINAL MESSAGE AND EXIT
    ; ========================================================================
    
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg2
    mov     rdx, msg2_len
    syscall
    
    mov     rax, 60
    xor     rdi, rdi
    syscall

; ========================================================================
; DATA FOR JUMP TABLE
; ========================================================================
section .data
    jump_table:  dq switch_case0, switch_case1, switch_case2

; ============================================================================
; NOTES:
; ============================================================================
; 
; FLAGS REGISTER (RFLAGS) - Key bits:
;   CF (bit 0)  - Carry Flag
;   PF (bit 2)  - Parity Flag
;   AF (bit 4)  - Auxiliary Carry Flag
;   ZF (bit 6)  - Zero Flag
;   SF (bit 7)  - Sign Flag
;   OF (bit 11) - Overflow Flag
;   DF (bit 10) - Direction Flag
;
; Conditional Jump Summary:
;   After CMP a, b (computes a - b):
;   
;   Signed:                  Unsigned:
;   JE  - a == b            JE  - a == b
;   JNE - a != b            JNE - a != b
;   JG  - a > b             JA  - a > b
;   JGE - a >= b            JAE - a >= b
;   JL  - a < b             JB  - a < b
;   JLE - a <= b            JBE - a <= b
;
; Performance Considerations:
;   - Modern CPUs have branch prediction
;   - Mispredicted branches cost 10-20 cycles
;   - Use CMOV for simple conditions (no branches)
;   - Predictable branches are fast
;   - Use jump tables for multi-way branches (switch)
;
; Best Practices:
;   - Keep loops tight (small body)
;   - Avoid branches in hot loops when possible
;   - Put likely code path first
;   - Use structured patterns (clear entry/exit points)
; ============================================================================

