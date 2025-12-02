; ============================================================================
; File: 01_hello_world.asm
; Description: Basic "Hello, World!" program demonstrating system calls
; Topics: System calls, data section, text section, program structure
; Assembler: NASM
; Build: nasm -f elf64 01_hello_world.asm && ld -o 01_hello_world 01_hello_world.o
; Run: ./01_hello_world
; ============================================================================

; The 'global' directive exports the _start symbol, making it visible to the linker
global _start

; ============================================================================
; DATA SECTION - Contains initialized data
; ============================================================================
section .data
    ; Define a string with a newline character
    ; db = define byte
    ; The string is null-terminated style with explicit length
    msg:        db "Hello, World!", 0x0a    ; 0x0a is newline character
    msg_len:    equ $ - msg                  ; Calculate length: current position ($) - start of msg

; ============================================================================
; TEXT SECTION - Contains executable code
; ============================================================================
section .text

_start:
    ; ========================================================================
    ; SYSTEM CALL: write
    ; ========================================================================
    ; Write "Hello, World!" to stdout (file descriptor 1)
    ;
    ; System call number for write is 1
    ; Arguments (System V AMD64 ABI):
    ;   rax = syscall number (1 for write)
    ;   rdi = file descriptor (1 for stdout)
    ;   rsi = pointer to buffer
    ;   rdx = number of bytes to write
    
    mov     rax, 1          ; System call number 1 = sys_write
    mov     rdi, 1          ; File descriptor 1 = stdout
    mov     rsi, msg        ; Address of string to write
    mov     rdx, msg_len    ; Number of bytes to write
    syscall                 ; Invoke system call

    ; ========================================================================
    ; SYSTEM CALL: exit
    ; ========================================================================
    ; Exit the program with return code 0 (success)
    ;
    ; System call number for exit is 60
    ; Arguments:
    ;   rax = syscall number (60 for exit)
    ;   rdi = exit status code (0 for success)
    
    mov     rax, 60         ; System call number 60 = sys_exit
    mov     rdi, 0          ; Exit status code 0 = success
    syscall                 ; Invoke system call

; ============================================================================
; NOTES:
; ============================================================================
; 1. The program must have a _start label, which is the entry point
; 2. System calls are made using the 'syscall' instruction (x86_64)
; 3. Return values from syscalls are in rax (negative = error)
; 4. The $ symbol represents the current position in the code/data
; 5. equ defines a constant (evaluated at assembly time)
; 6. Labels (like msg:) are memory addresses
;
; Register Usage Summary:
;   RAX - System call number and return value
;   RDI - 1st argument (file descriptor)
;   RSI - 2nd argument (buffer pointer)
;   RDX - 3rd argument (byte count)
;
; Common File Descriptors:
;   0 = stdin  (standard input)
;   1 = stdout (standard output)
;   2 = stderr (standard error)
; ============================================================================

