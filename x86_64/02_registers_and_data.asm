; ============================================================================
; File: 02_registers_and_data.asm
; Description: Demonstrates register operations and data types
; Topics: Registers, mov instruction, data types, arithmetic operations
; Assembler: NASM
; Build: nasm -f elf64 02_registers_and_data.asm && ld -o 02_registers_and_data 02_registers_and_data.o
; ============================================================================

global _start

section .data
    ; Different data types in x86_64:
    
    byte_val:       db  0xFF                ; Define Byte (8-bit): 255
    word_val:       dw  0xFFFF              ; Define Word (16-bit): 65535
    dword_val:      dd  0xFFFFFFFF          ; Define Double Word (32-bit): 4294967295
    qword_val:      dq  0xFFFFFFFFFFFFFFFF  ; Define Quad Word (64-bit): max 64-bit value
    
    ; Arrays of data
    byte_array:     db  10, 20, 30, 40, 50     ; Array of 5 bytes
    word_array:     dw  1000, 2000, 3000        ; Array of 3 words
    
    ; Strings are just byte arrays
    string:         db  "Hello", 0              ; Null-terminated string
    
    ; Floating point values
    float_val:      dd  3.14159                 ; 32-bit float
    double_val:     dq  2.718281828             ; 64-bit double
    
    ; Uninitialized data goes in .bss section

section .bss
    ; Reserve uninitialized space
    buffer:         resb 64     ; Reserve 64 bytes
    counter:        resq 1      ; Reserve 1 quad word (8 bytes)

section .text

_start:
    ; ========================================================================
    ; BASIC REGISTER OPERATIONS
    ; ========================================================================
    
    ; Moving immediate values to registers
    mov     rax, 42             ; Move immediate value 42 to RAX
    mov     rbx, 0x1000         ; Move hex value to RBX
    mov     rcx, -1             ; Move -1 (0xFFFFFFFFFFFFFFFF) to RCX
    
    ; ========================================================================
    ; REGISTER-TO-REGISTER MOVES
    ; ========================================================================
    
    mov     rdx, rax            ; Copy RAX to RDX
    mov     rsi, rbx            ; Copy RBX to RSI
    
    ; ========================================================================
    ; ACCESSING DIFFERENT REGISTER SIZES
    ; ========================================================================
    
    ; RAX is 64-bit, but we can access smaller parts:
    mov     rax, 0x1122334455667788    ; Set entire 64-bit register
    
    ; Now RAX contains: 0x1122334455667788
    ;   RAX (64-bit): 0x1122334455667788
    ;   EAX (32-bit): 0x55667788 (lower 32 bits)
    ;   AX  (16-bit): 0x7788 (lower 16 bits)
    ;   AH  (8-bit):  0x77 (bits 15-8)
    ;   AL  (8-bit):  0x88 (bits 7-0)
    
    mov     al, 0xFF            ; Modify only lowest byte (AL)
                                ; RAX is now: 0x11223344556677FF
    
    mov     ah, 0xAA            ; Modify bits 15-8 (AH)
                                ; RAX is now: 0x1122334455667AFF
    
    mov     ax, 0xBEEF          ; Modify lowest 16 bits (AX)
                                ; RAX is now: 0x112233445566BEEF
    
    mov     eax, 0x12345678     ; Modify lowest 32 bits (EAX)
                                ; RAX is now: 0x0000000012345678
                                ; NOTE: Writing to 32-bit register ZEROS upper 32 bits!
    
    ; ========================================================================
    ; LOADING FROM MEMORY
    ; ========================================================================
    
    ; Load different sizes from memory
    mov     al, [byte_val]      ; Load 1 byte from memory
    mov     ax, [word_val]      ; Load 2 bytes (word) from memory
    mov     eax, [dword_val]    ; Load 4 bytes (dword) from memory
    mov     rax, [qword_val]    ; Load 8 bytes (qword) from memory
    
    ; ========================================================================
    ; STORING TO MEMORY
    ; ========================================================================
    
    mov     rax, 0x123456789ABCDEF0
    mov     [counter], rax      ; Store 8 bytes to memory
    
    ; We can also use explicit size directives:
    mov     BYTE [buffer], 0x42         ; Store 1 byte
    mov     WORD [buffer + 1], 0x1234   ; Store 2 bytes at offset 1
    mov     DWORD [buffer + 3], 0x87654321   ; Store 4 bytes at offset 3
    mov     QWORD [buffer + 7], rax     ; Store 8 bytes at offset 7
    
    ; ========================================================================
    ; BASIC ARITHMETIC
    ; ========================================================================
    
    ; Addition
    mov     rax, 10
    add     rax, 5              ; RAX = RAX + 5 = 15
    
    ; Subtraction
    mov     rbx, 20
    sub     rbx, 7              ; RBX = RBX - 7 = 13
    
    ; Increment and Decrement
    inc     rax                 ; RAX = RAX + 1 = 16
    dec     rbx                 ; RBX = RBX - 1 = 12
    
    ; Multiplication (unsigned)
    mov     rax, 5
    mov     rbx, 3
    mul     rbx                 ; RAX = RAX * RBX = 15
                                ; Note: Result in RDX:RAX (RDX has high bits)
    
    ; Signed multiplication
    mov     rax, -5
    mov     rbx, 3
    imul    rbx                 ; RAX = RAX * RBX = -15 (signed)
    
    ; Alternative imul forms:
    imul    rax, rbx            ; RAX = RAX * RBX
    imul    rax, rbx, 10        ; RAX = RBX * 10
    
    ; Division (unsigned)
    mov     rax, 20
    mov     rdx, 0              ; Must clear RDX for division!
    mov     rbx, 3
    div     rbx                 ; RAX = quotient (6), RDX = remainder (2)
    
    ; ========================================================================
    ; LOGICAL OPERATIONS
    ; ========================================================================
    
    ; AND - Each bit is 1 only if both corresponding bits are 1
    mov     rax, 0b11110000     ; Binary notation (240 in decimal)
    mov     rbx, 0b11001100     ; Binary notation (204 in decimal)
    and     rax, rbx            ; RAX = 0b11000000 (192)
    
    ; OR - Each bit is 1 if either corresponding bit is 1
    mov     rax, 0b11110000
    mov     rbx, 0b11001100
    or      rax, rbx            ; RAX = 0b11111100 (252)
    
    ; XOR - Each bit is 1 if corresponding bits are different
    mov     rax, 0b11110000
    mov     rbx, 0b11001100
    xor     rax, rbx            ; RAX = 0b00111100 (60)
    
    ; XOR trick: Clear a register (faster than mov reg, 0)
    xor     rax, rax            ; RAX = 0
    
    ; NOT - Invert all bits
    mov     rax, 0b11110000
    not     rax                 ; RAX = 0b...00001111 (bitwise complement)
    
    ; ========================================================================
    ; SHIFT AND ROTATE OPERATIONS
    ; ========================================================================
    
    ; Shift Left Logical (multiply by 2^n)
    mov     rax, 5              ; 0b101
    shl     rax, 1              ; RAX = 10 (0b1010) - multiplied by 2
    shl     rax, 2              ; RAX = 40 (0b101000) - multiplied by 4
    
    ; Shift Right Logical (unsigned divide by 2^n)
    mov     rax, 40
    shr     rax, 2              ; RAX = 10 (divide by 4)
    
    ; Shift Right Arithmetic (signed divide by 2^n, preserves sign bit)
    mov     rax, -40
    sar     rax, 2              ; RAX = -10 (signed division by 4)
    
    ; Rotate Left (bits wrap around)
    mov     rax, 0x8000000000000001
    rol     rax, 1              ; RAX = 0x0000000000000003 (high bit moved to low)
    
    ; Rotate Right
    mov     rax, 0x8000000000000001
    ror     rax, 1              ; RAX = 0xC000000000000000
    
    ; ========================================================================
    ; LEA - Load Effective Address (powerful instruction!)
    ; ========================================================================
    
    ; LEA calculates address but doesn't dereference
    ; Can be used for arithmetic without affecting flags
    
    mov     rbx, 100
    lea     rax, [rbx + 50]     ; RAX = RBX + 50 = 150 (just arithmetic!)
    lea     rax, [rbx + rbx*4]  ; RAX = RBX * 5 = 500 (multiply by 5!)
    lea     rax, [rbx + rbx*8 + 10]  ; RAX = RBX * 9 + 10 = 910
    
    ; LEA is often used for fast multiplication by small constants:
    ; multiply by 2: lea rax, [rbx + rbx]
    ; multiply by 3: lea rax, [rbx + rbx*2]
    ; multiply by 5: lea rax, [rbx + rbx*4]
    ; multiply by 9: lea rax, [rbx + rbx*8]
    
    ; ========================================================================
    ; EXCHANGE OPERATIONS
    ; ========================================================================
    
    ; Swap two registers
    mov     rax, 10
    mov     rbx, 20
    xchg    rax, rbx            ; RAX = 20, RBX = 10 (atomic operation)
    
    ; ========================================================================
    ; CONDITIONAL MOVE (CMOV)
    ; ========================================================================
    
    ; Move only if condition is true (avoids branching!)
    mov     rax, 100
    mov     rbx, 200
    cmp     rax, rbx            ; Compare RAX and RBX (sets flags)
    cmovl   rax, rbx            ; Move RBX to RAX if RAX < RBX (signed)
                                ; RAX is now 200
    
    ; ========================================================================
    ; ZERO AND SIGN EXTENSION
    ; ========================================================================
    
    ; Zero extension: extend with zeros
    mov     al, 0xFF            ; AL = 255 (signed: -1)
    movzx   rax, al             ; RAX = 0x00000000000000FF (zero extended)
    
    ; Sign extension: extend with sign bit
    mov     al, 0xFF            ; AL = -1 (signed)
    movsx   rax, al             ; RAX = 0xFFFFFFFFFFFFFFFF (sign extended)
    
    ; ========================================================================
    ; EXIT PROGRAM
    ; ========================================================================
    
    mov     rax, 60             ; sys_exit
    xor     rdi, rdi            ; Exit code 0 (using XOR to clear)
    syscall

; ============================================================================
; NOTES AND REGISTER REFERENCE:
; ============================================================================
;
; General Purpose Registers (16 total in x86_64):
;   RAX, RBX, RCX, RDX - Legacy registers with special uses
;   RSI, RDI           - Source and Destination Index
;   RBP, RSP           - Base and Stack Pointer
;   R8-R15             - Additional general purpose registers
;
; Special Uses:
;   RAX - Accumulator (syscall number, return value, arithmetic)
;   RBX - Base register
;   RCX - Counter (for loops, shifts, etc.)
;   RDX - Data register (I/O operations, extended arithmetic)
;   RSI - Source index for string operations
;   RDI - Destination index for string operations
;   RBP - Base pointer (stack frame)
;   RSP - Stack pointer (top of stack)
;
; Instruction Formats:
;   mov dest, source        ; Copy source to destination
;   add dest, source        ; dest = dest + source
;   sub dest, source        ; dest = dest - source
;   and/or/xor dest, source ; Logical operations
;   shl/shr reg, count      ; Shift operations
;   lea dest, [address]     ; Calculate effective address
;
; Memory Access:
;   [address]               ; Dereference address
;   [reg]                   ; Use register as address
;   [reg + offset]          ; Base + displacement
;   [reg1 + reg2]           ; Base + index
;   [reg1 + reg2*scale]     ; Base + scaled index (scale: 1,2,4,8)
;   [reg1 + reg2*scale + disp] ; Full SIB addressing
; ============================================================================

