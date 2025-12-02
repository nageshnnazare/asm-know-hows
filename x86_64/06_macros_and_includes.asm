; ============================================================================
; File: 06_macros_and_includes.asm
; Description: Demonstrates macros, includes, and code organization
; Topics: Macros, %include, multi-line macros, conditional assembly
; Assembler: NASM
; Build: nasm -f elf64 06_macros_and_includes.asm && ld -o 06_macros_and_includes 06_macros_and_includes.o
; ============================================================================

; ============================================================================
; SIMPLE MACROS
; ============================================================================

; Define a simple macro (text substitution)
%define SYS_EXIT    60
%define SYS_WRITE   1
%define STDOUT      1

; Macro with parameters
%define mov64(reg, val) mov reg, val

; ============================================================================
; MULTI-LINE MACROS
; ============================================================================

; Macro for printing a string
%macro print_string 2          ; Macro name and number of parameters
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, %1            ; First parameter: string address
    mov     rdx, %2            ; Second parameter: string length
    syscall
%endmacro

; Macro for exiting program
%macro exit_program 1
    mov     rax, SYS_EXIT
    mov     rdi, %1            ; Exit code
    syscall
%endmacro

; Macro for function prologue
%macro prologue 0
    push    rbp
    mov     rbp, rsp
%endmacro

; Macro for function epilogue
%macro epilogue 0
    mov     rsp, rbp
    pop     rbp
    ret
%endmacro

; Macro with local labels
%macro save_registers 0
    push    rax
    push    rbx
    push    rcx
    push    rdx
%endmacro

%macro restore_registers 0
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
%endmacro

; ============================================================================
; ADVANCED MACROS
; ============================================================================

; Macro with default parameters
%macro print 1-2 STDOUT        ; 1-2 parameters, 2nd defaults to STDOUT
    mov     rax, SYS_WRITE
    mov     rdi, %2            ; Second parameter (or default)
    mov     rsi, %1            ; First parameter
    call    strlen
    mov     rdx, rax
    mov     rax, SYS_WRITE
    syscall
%endmacro

; Macro for push multiple registers
%macro pushm 1-*               ; Variable number of parameters
    %rep %0                    ; %0 = number of parameters
        push %1                ; Push current parameter
        %rotate 1              ; Rotate to next parameter
    %endrep
%endmacro

; Macro for pop multiple registers (reverse order)
%macro popm 1-*
    %rep %0
        %rotate -1             ; Rotate backwards
        pop %1
    %endrep
%endmacro

; Conditional macro
%macro debug_print 1
    %ifdef DEBUG               ; Only include if DEBUG is defined
        print_string %1, debug_msg_len
    %endif
%endmacro

; Macro for loop boilerplate
%macro for_loop 4              ; start, end, step, label
    mov     rcx, %1            ; Start value
%%loop_start:
    cmp     rcx, %2            ; Compare with end
    jge     %%loop_end         ; Exit if >= end
    
    ; Loop body goes here (caller adds this)
    %3                         ; Step (e.g., inc rcx)
    jmp     %%loop_start
%%loop_end:
%endmacro

; ============================================================================
; CONDITIONAL ASSEMBLY
; ============================================================================

; Define compile-time constants
%define VERSION 1
%define DEBUG_MODE

; Conditional compilation
%ifdef DEBUG_MODE
    %define LOG_ENABLED
%endif

; ============================================================================
; LOCAL LABELS IN MACROS
; ============================================================================

%macro conditional_move 3      ; condition, dest, source
    cmp     %1, 0
    je      %%skip
    mov     %2, %3
%%skip:
%endmacro

; ============================================================================
; MACRO FOR SYSTEM CALL WRAPPER
; ============================================================================

%macro syscall_wrapper 1-7     ; syscall_number, arg1-arg6
    mov     rax, %1            ; System call number
    
    %if %0 > 1
        mov rdi, %2            ; First argument
    %endif
    %if %0 > 2
        mov rsi, %3            ; Second argument
    %endif
    %if %0 > 3
        mov rdx, %4            ; Third argument
    %endif
    %if %0 > 4
        mov r10, %5            ; Fourth argument
    %endif
    %if %0 > 5
        mov r8, %6             ; Fifth argument
    %endif
    %if %0 > 6
        mov r9, %7             ; Sixth argument
    %endif
    
    syscall
%endmacro

; ============================================================================
; MACROS FOR COMMON OPERATIONS
; ============================================================================

; Clear register (XOR is faster than MOV reg, 0)
%macro clear 1
    xor     %1, %1
%endmacro

; Swap two registers using XOR (no temporary needed)
%macro swap 2
    xor     %1, %2
    xor     %2, %1
    xor     %1, %2
%endmacro

; Absolute value
%macro abs 1
    cmp     %1, 0
    jge     %%positive
    neg     %1
%%positive:
%endmacro

; Min of two values
%macro min 3                   ; result, val1, val2
    mov     %1, %2
    cmp     %1, %3
    cmovg   %1, %3
%endmacro

; Max of two values
%macro max 3                   ; result, val1, val2
    mov     %1, %2
    cmp     %1, %3
    cmovl   %1, %3
%endmacro

; ============================================================================
; MACRO FOR TIMING CODE
; ============================================================================

%macro rdtsc_start 0
    cpuid                      ; Serialize
    rdtsc                      ; Read time-stamp counter
    mov     [time_start], eax
    mov     [time_start + 4], edx
%endmacro

%macro rdtsc_end 0
    rdtsc                      ; Read time-stamp counter
    mov     [time_end], eax
    mov     [time_end + 4], edx
%endmacro

; ============================================================================
; DATA SECTION
; ============================================================================

global _start

section .data
    msg1:       db "Hello from macro!", 0x0a
    msg1_len:   equ $ - msg1
    
    msg2:       db "Testing macros...", 0x0a
    msg2_len:   equ $ - msg2
    
    msg3:       db "Prologue/Epilogue test", 0x0a
    msg3_len:   equ $ - msg3
    
    newline:    db 0x0a
    
    %ifdef DEBUG_MODE
    debug_msg:  db "DEBUG: Macro expanded", 0x0a
    debug_msg_len: equ $ - debug_msg
    %endif

section .bss
    time_start: resq 1
    time_end:   resq 1
    temp_buffer: resb 100

section .text

_start:
    ; ========================================================================
    ; USING SIMPLE MACROS
    ; ========================================================================
    
    ; Use defined constants
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    
    ; ========================================================================
    ; USING PRINT MACRO
    ; ========================================================================
    
    print_string msg1, msg1_len    ; Expand macro
    print_string msg2, msg2_len
    
    ; ========================================================================
    ; USING REGISTER SAVE/RESTORE MACROS
    ; ========================================================================
    
    mov     rax, 100
    mov     rbx, 200
    mov     rcx, 300
    mov     rdx, 400
    
    save_registers             ; Push all to stack
    
    ; Modify registers
    clear rax                  ; Use clear macro
    clear rbx
    clear rcx
    clear rdx
    
    restore_registers          ; Restore from stack
    ; RAX, RBX, RCX, RDX back to original values
    
    ; ========================================================================
    ; USING PUSH/POP MULTIPLE MACRO
    ; ========================================================================
    
    pushm rax, rbx, rcx, rdx   ; Push multiple registers
    
    ; Do something
    mov     rax, 1
    mov     rbx, 2
    
    popm rax, rbx, rcx, rdx    ; Pop in reverse order
    
    ; ========================================================================
    ; USING CONDITIONAL MOVE MACRO
    ; ========================================================================
    
    mov     rax, 10
    mov     rbx, 20
    conditional_move rax, rcx, rbx  ; If RAX != 0, RCX = RBX
    
    ; ========================================================================
    ; USING MIN/MAX MACROS
    ; ========================================================================
    
    mov     rax, 50
    mov     rbx, 30
    min     rcx, rax, rbx      ; RCX = min(RAX, RBX) = 30
    
    mov     rax, 50
    mov     rbx, 30
    max     rdx, rax, rbx      ; RDX = max(RAX, RBX) = 50
    
    ; ========================================================================
    ; USING SWAP MACRO
    ; ========================================================================
    
    mov     rax, 100
    mov     rbx, 200
    swap    rax, rbx           ; RAX=200, RBX=100
    
    ; ========================================================================
    ; USING ABSOLUTE VALUE MACRO
    ; ========================================================================
    
    mov     rax, -50
    abs     rax                ; RAX = 50
    
    ; ========================================================================
    ; CALLING FUNCTION WITH PROLOGUE/EPILOGUE MACROS
    ; ========================================================================
    
    mov     rdi, 10
    mov     rsi, 20
    call    add_function
    ; RAX = 30
    
    ; ========================================================================
    ; CONDITIONAL DEBUG PRINTING
    ; ========================================================================
    
    debug_print debug_msg      ; Only prints if DEBUG defined
    
    ; ========================================================================
    ; USING SYSCALL WRAPPER
    ; ========================================================================
    
    ; Write system call using wrapper
    syscall_wrapper SYS_WRITE, STDOUT, msg3, msg3_len
    
    ; ========================================================================
    ; TIMING EXAMPLE
    ; ========================================================================
    
    ; Time a piece of code
    rdtsc_start
    
    ; Code to time
    mov     rcx, 1000000
.timing_loop:
    dec     rcx
    jnz     .timing_loop
    
    rdtsc_end
    
    ; Calculate elapsed cycles
    mov     eax, [time_end]
    mov     edx, [time_end + 4]
    sub     eax, [time_start]
    sbb     edx, [time_start + 4]
    ; Result in EDX:EAX
    
    ; ========================================================================
    ; EXIT
    ; ========================================================================
    
    exit_program 0             ; Use exit macro

; ============================================================================
; FUNCTION USING PROLOGUE/EPILOGUE MACROS
; ============================================================================
add_function:
    prologue                   ; Expand prologue macro
    
    mov     rax, rdi
    add     rax, rsi
    
    epilogue                   ; Expand epilogue macro

; ============================================================================
; HELPER FUNCTION: strlen (for variable-length print)
; ============================================================================
strlen:
    push    rdi
    xor     rax, rax
    
.loop:
    cmp     byte [rdi], 0
    je      .done
    inc     rax
    inc     rdi
    jmp     .loop
    
.done:
    pop     rdi
    ret

; ============================================================================
; EXAMPLE: FUNCTION-LIKE MACRO vs ACTUAL FUNCTION
; ============================================================================

; Function-like macro (inlined, no call overhead)
%macro square_macro 1          ; result = arg^2
    mov     %1, %1
    imul    %1, %1
%endmacro

; Actual function (call overhead, but code size smaller if called multiple times)
square_function:
    prologue
    imul    rdi, rdi
    mov     rax, rdi
    epilogue

; ============================================================================
; NOTES ON MACROS
; ============================================================================
;
; NASM Macro Features:
; ┌────────────────────────────────────────────────────────────────────┐
; │ %define  - Simple text substitution                                │
; │ %macro   - Multi-line macro with parameters                        │
; │ %rep     - Repeat block N times                                    │
; │ %if      - Conditional assembly                                    │
; │ %ifdef   - Check if symbol defined                                 │
; │ %include - Include another file                                    │
; │ %%label  - Local label within macro                                │
; │ %0       - Number of parameters passed to macro                    │
; │ %1, %2   - Macro parameters                                        │
; │ %rotate  - Rotate macro parameter list                             │
; └────────────────────────────────────────────────────────────────────┘
;
; Macro Benefits:
;   + Code reuse
;   + Readability
;   + No function call overhead (inlined)
;   + Conditional compilation
;
; Macro Drawbacks:
;   - Increases code size (each use expands)
;   - No type checking
;   - Debugging can be harder
;   - Can make code less clear if overused
;
; When to Use Macros:
;   ✓ Common short code sequences
;   ✓ Boilerplate code (prologue/epilogue)
;   ✓ Conditional compilation
;   ✓ Code that needs to be fast (no call overhead)
;
; When to Use Functions:
;   ✓ Large code blocks
;   ✓ Called many times (smaller code size)
;   ✓ Recursive code
;   ✓ Better debugging needed
;
; Best Practices:
;   1. Use descriptive macro names
;   2. Document macro parameters
;   3. Use local labels (%%) to avoid conflicts
;   4. Keep macros simple and focused
;   5. Consider using functions for complex logic
;   6. Use %ifdef for platform-specific code
;
; Predefined Macros (NASM):
;   __NASM_VERSION__  - NASM version
;   __FILE__          - Current file name
;   __LINE__          - Current line number
;   __DATE__          - Assembly date
;   __TIME__          - Assembly time
;
; ============================================================================

