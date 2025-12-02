; ============================================================================
; File: 05_strings_and_arrays.asm
; Description: String manipulation and array operations
; Topics: String instructions, array access, memory operations
; Assembler: NASM
; Build: nasm -f elf64 05_strings_and_arrays.asm && ld -o 05_strings_and_arrays 05_strings_and_arrays.o
; ============================================================================

global _start

section .data
    ; Strings
    source_str:     db "Hello, Assembly!", 0
    source_len:     equ $ - source_str - 1
    
    search_char:    db 'A'
    
    ; Arrays
    byte_array:     db 10, 20, 30, 40, 50
    byte_array_len: equ $ - byte_array
    
    int_array:      dq 100, 200, 300, 400, 500  ; Array of quad words
    int_array_len:  equ 5
    
    msg_found:      db "Character found!", 0x0a
    msg_found_len:  equ $ - msg_found
    
    msg_not_found:  db "Character not found!", 0x0a
    msg_not_found_len: equ $ - msg_not_found

section .bss
    dest_buffer:    resb 100        ; Destination buffer for string operations
    temp_buffer:    resb 100        ; Temporary buffer
    result_array:   resq 10         ; Result array (10 quad words)

section .text

_start:
    ; ========================================================================
    ; BASIC STRING OPERATIONS - Manual
    ; ========================================================================
    
    ; Copy string byte by byte (manual loop)
    lea     rsi, [source_str]       ; Source address
    lea     rdi, [dest_buffer]      ; Destination address
    mov     rcx, source_len         ; Length
    
copy_loop:
    cmp     rcx, 0
    je      copy_done
    
    mov     al, [rsi]               ; Load byte from source
    mov     [rdi], al               ; Store byte to destination
    
    inc     rsi                     ; Advance source pointer
    inc     rdi                     ; Advance destination pointer
    dec     rcx                     ; Decrement counter
    
    jmp     copy_loop
    
copy_done:
    mov     byte [rdi], 0           ; Null terminate
    
    ; ========================================================================
    ; STRING INSTRUCTIONS - Using REP prefix
    ; ========================================================================
    
    ; x86_64 provides special string instructions:
    ; MOVSB/MOVSW/MOVSD/MOVSQ - Move string (byte/word/dword/qword)
    ; CMPSB/CMPSW/CMPSD/CMPSQ - Compare string
    ; SCASB/SCASW/SCASD/SCASQ - Scan string (search)
    ; LODSB/LODSW/LODSD/LODSQ - Load string
    ; STOSB/STOSW/STOSD/STOSQ - Store string
    ;
    ; REP prefix repeats instruction RCX times
    ; REPE/REPZ - Repeat while equal/zero
    ; REPNE/REPNZ - Repeat while not equal/not zero
    
    ; ========================================================================
    ; MOVSB - Move String Byte
    ; ========================================================================
    
    ; Copy string using MOVSB (more efficient)
    lea     rsi, [source_str]       ; Source
    lea     rdi, [dest_buffer]      ; Destination
    mov     rcx, source_len         ; Count
    cld                             ; Clear direction flag (increment)
    rep     movsb                   ; Repeat: move byte [RSI] to [RDI], inc both
    
    ; Alternative: MOVSQ for 8-byte chunks (faster for large copies)
    lea     rsi, [source_str]
    lea     rdi, [temp_buffer]
    mov     rcx, source_len
    add     rcx, 7                  ; Round up
    shr     rcx, 3                  ; Divide by 8 (number of qwords)
    cld
    rep     movsq                   ; Move 8 bytes at a time
    
    ; ========================================================================
    ; STOSB - Store String Byte (Fill memory)
    ; ========================================================================
    
    ; Fill buffer with a value (memset equivalent)
    lea     rdi, [temp_buffer]      ; Destination
    mov     al, 0xFF                ; Value to fill
    mov     rcx, 50                 ; Count
    cld
    rep     stosb                   ; Repeat: store AL to [RDI], inc RDI
    
    ; Clear buffer (fill with zeros)
    lea     rdi, [temp_buffer]
    xor     al, al                  ; AL = 0
    mov     rcx, 100
    cld
    rep     stosb
    
    ; ========================================================================
    ; SCASB - Scan String Byte (Search for character)
    ; ========================================================================
    
    ; Search for character in string
    lea     rdi, [source_str]       ; String to search
    mov     al, 'A'                 ; Character to find
    mov     rcx, source_len         ; Length
    cld
    repne   scasb                   ; Repeat while not equal: compare AL with [RDI]
    
    ; If found, ZF=1 and RDI points one byte AFTER the match
    jne     char_not_found
    
    ; Character found!
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_found
    mov     rdx, msg_found_len
    syscall
    jmp     after_search
    
char_not_found:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_not_found
    mov     rdx, msg_not_found_len
    syscall
    
after_search:
    
    ; ========================================================================
    ; CMPSB - Compare String Bytes
    ; ========================================================================
    
    ; Compare two strings
    lea     rsi, [source_str]       ; First string
    lea     rdi, [dest_buffer]      ; Second string
    mov     rcx, source_len         ; Length
    cld
    repe    cmpsb                   ; Repeat while equal: compare [RSI] with [RDI]
    
    ; If equal, ZF=1 after comparison
    ; If not equal, ZF=0 and RSI, RDI point past first mismatch
    
    ; ========================================================================
    ; LODSB - Load String Byte (Read and advance)
    ; ========================================================================
    
    ; Process string character by character
    lea     rsi, [source_str]       ; Source string
    mov     rcx, source_len
    
process_loop:
    cmp     rcx, 0
    je      process_done
    
    lodsb                           ; Load [RSI] into AL, inc RSI
    
    ; Process character in AL (e.g., convert to uppercase)
    cmp     al, 'a'
    jl      .not_lowercase
    cmp     al, 'z'
    jg      .not_lowercase
    
    sub     al, 32                  ; Convert to uppercase
    
.not_lowercase:
    ; Do something with processed character
    
    dec     rcx
    jmp     process_loop
    
process_done:
    
    ; ========================================================================
    ; DIRECTION FLAG
    ; ========================================================================
    
    ; DF (Direction Flag) controls string operation direction:
    ; DF=0 (CLD): Increment RSI/RDI (forward)
    ; DF=1 (STD): Decrement RSI/RDI (backward)
    
    ; Copy string backwards
    lea     rsi, [source_str + source_len - 1]  ; End of source
    lea     rdi, [temp_buffer + source_len - 1] ; End of destination
    mov     rcx, source_len
    std                             ; Set direction flag (decrement)
    rep     movsb
    cld                             ; Always clear DF when done!
    
    ; ========================================================================
    ; ARRAY ACCESS - Byte Array
    ; ========================================================================
    
    ; Access array elements
    lea     rbx, [byte_array]       ; Base address
    
    ; Access element at index 2 (0-based)
    mov     al, [rbx + 2]           ; AL = 30
    
    ; Loop through array
    xor     rcx, rcx                ; Index = 0
    
byte_array_loop:
    cmp     rcx, byte_array_len
    jge     byte_array_done
    
    mov     al, [rbx + rcx]         ; Load element
    ; Process element in AL
    add     al, 10                  ; Add 10 to each element
    mov     [rbx + rcx], al         ; Store back
    
    inc     rcx
    jmp     byte_array_loop
    
byte_array_done:
    
    ; ========================================================================
    ; ARRAY ACCESS - Multi-byte Elements (Scaled Indexing)
    ; ========================================================================
    
    ; Access quad word array (8 bytes per element)
    lea     rbx, [int_array]        ; Base address
    
    ; Access element at index 2
    ; Address = base + index * element_size
    mov     rax, [rbx + 2*8]        ; RAX = 300 (third element)
    
    ; Using scaled indexing
    mov     rcx, 2                  ; Index
    mov     rax, [rbx + rcx*8]      ; RAX = int_array[2]
    
    ; Loop through integer array
    xor     rcx, rcx                ; Index = 0
    
int_array_loop:
    cmp     rcx, int_array_len
    jge     int_array_done
    
    mov     rax, [rbx + rcx*8]      ; Load element (scale by 8)
    
    ; Process element in RAX
    add     rax, 1000               ; Add 1000 to each element
    
    mov     [rbx + rcx*8], rax      ; Store back
    
    inc     rcx
    jmp     int_array_loop
    
int_array_done:
    
    ; ========================================================================
    ; SIB ADDRESSING - Scale-Index-Base
    ; ========================================================================
    
    ; Format: [base + index*scale + displacement]
    ; scale can be 1, 2, 4, or 8
    
    lea     rbx, [int_array]        ; Base
    mov     rcx, 3                  ; Index
    
    ; Access int_array[3] with offset
    mov     rax, [rbx + rcx*8 + 0]  ; Full SIB addressing
    
    ; ========================================================================
    ; MULTI-DIMENSIONAL ARRAYS
    ; ========================================================================
    
    ; For a 2D array: array[rows][cols]
    ; Element at [i][j] is at: base + (i * cols + j) * element_size
    
    ; Example: 3x4 array of quad words
    ; array[1][2] = base + (1 * 4 + 2) * 8 = base + 48
    
    ; Given: i=1, j=2, cols=4, element_size=8
    mov     rsi, 1                  ; i
    mov     rdi, 2                  ; j
    mov     rax, 4                  ; cols
    
    imul    rax, rsi                ; RAX = i * cols
    add     rax, rdi                ; RAX = i * cols + j
    
    lea     rbx, [int_array]        ; Base (pretend it's 2D)
    mov     rcx, [rbx + rax*8]      ; Load array[i][j]
    
    ; ========================================================================
    ; STRING LENGTH FUNCTION
    ; ========================================================================
    
    lea     rdi, [source_str]
    call    strlen
    ; RAX now contains length
    mov     r12, rax
    
    ; ========================================================================
    ; STRING COPY FUNCTION
    ; ========================================================================
    
    lea     rdi, [temp_buffer]      ; Destination
    lea     rsi, [source_str]       ; Source
    call    strcpy
    
    ; ========================================================================
    ; STRING COMPARE FUNCTION
    ; ========================================================================
    
    lea     rdi, [source_str]
    lea     rsi, [dest_buffer]
    call    strcmp
    ; RAX = 0 if equal, <0 if str1 < str2, >0 if str1 > str2
    
    ; ========================================================================
    ; ARRAY SUM FUNCTION
    ; ========================================================================
    
    lea     rdi, [int_array]        ; Array address
    mov     rsi, int_array_len      ; Array length
    call    array_sum
    ; RAX contains sum
    mov     r13, rax
    
    ; ========================================================================
    ; ARRAY REVERSE FUNCTION
    ; ========================================================================
    
    lea     rdi, [int_array]
    mov     rsi, int_array_len
    call    array_reverse
    
    ; Exit
    mov     rax, 60
    xor     rdi, rdi
    syscall

; ============================================================================
; FUNCTION: strlen
; Description: Calculate string length (null-terminated)
; Arguments: RDI = string address
; Returns: RAX = length (excluding null terminator)
; ============================================================================
strlen:
    push    rdi
    xor     rax, rax                ; Length counter
    
.loop:
    cmp     byte [rdi], 0           ; Check for null terminator
    je      .done
    inc     rax
    inc     rdi
    jmp     .loop
    
.done:
    pop     rdi
    ret

; ============================================================================
; FUNCTION: strcpy
; Description: Copy null-terminated string
; Arguments: RDI = destination, RSI = source
; Returns: RDI = destination (preserved)
; ============================================================================
strcpy:
    push    rdi
    
.loop:
    mov     al, [rsi]               ; Load source byte
    mov     [rdi], al               ; Store to destination
    test    al, al                  ; Check if null
    jz      .done
    inc     rsi
    inc     rdi
    jmp     .loop
    
.done:
    pop     rdi
    ret

; ============================================================================
; FUNCTION: strcmp
; Description: Compare two null-terminated strings
; Arguments: RDI = string1, RSI = string2
; Returns: RAX = 0 (equal), <0 (str1 < str2), >0 (str1 > str2)
; ============================================================================
strcmp:
    push    rdi
    push    rsi
    
.loop:
    mov     al, [rdi]               ; Load char from string1
    mov     bl, [rsi]               ; Load char from string2
    
    cmp     al, bl
    jne     .not_equal              ; Characters differ
    
    test    al, al                  ; Check if null (end of both strings)
    jz      .equal
    
    inc     rdi
    inc     rsi
    jmp     .loop
    
.equal:
    xor     rax, rax                ; Return 0
    jmp     .done
    
.not_equal:
    movzx   rax, al                 ; Zero-extend AL to RAX
    movzx   rbx, bl                 ; Zero-extend BL to RBX
    sub     rax, rbx                ; RAX = difference
    
.done:
    pop     rsi
    pop     rdi
    ret

; ============================================================================
; FUNCTION: array_sum
; Description: Sum all elements in a quad word array
; Arguments: RDI = array address, RSI = array length
; Returns: RAX = sum
; ============================================================================
array_sum:
    xor     rax, rax                ; Sum = 0
    xor     rcx, rcx                ; Index = 0
    
.loop:
    cmp     rcx, rsi
    jge     .done
    
    add     rax, [rdi + rcx*8]      ; Add element to sum
    inc     rcx
    jmp     .loop
    
.done:
    ret

; ============================================================================
; FUNCTION: array_reverse
; Description: Reverse a quad word array in place
; Arguments: RDI = array address, RSI = array length
; ============================================================================
array_reverse:
    push    rbx
    push    rcx
    
    xor     rcx, rcx                ; Left index = 0
    mov     rbx, rsi                ; Right index = length
    dec     rbx                     ; Right index = length - 1
    
.loop:
    cmp     rcx, rbx
    jge     .done                   ; Stop when left >= right
    
    ; Swap array[left] and array[right]
    mov     rax, [rdi + rcx*8]      ; Temp = array[left]
    mov     r8, [rdi + rbx*8]       ; Load array[right]
    mov     [rdi + rbx*8], rax      ; array[right] = temp
    mov     [rdi + rcx*8], r8       ; array[left] = array[right]
    
    inc     rcx                     ; left++
    dec     rbx                     ; right--
    jmp     .loop
    
.done:
    pop     rcx
    pop     rbx
    ret

; ============================================================================
; NOTES:
; ============================================================================
;
; String Instructions Summary:
; ┌──────────┬────────────────────────────────────────────────────────┐
; │ MOVSB/Q  │ Move [RSI] to [RDI], advance both                     │
; │ STOSB/Q  │ Store AL/RAX to [RDI], advance RDI                    │
; │ LODSB/Q  │ Load [RSI] to AL/RAX, advance RSI                     │
; │ SCASB/Q  │ Compare AL/RAX with [RDI], advance RDI                │
; │ CMPSB/Q  │ Compare [RSI] with [RDI], advance both                │
; └──────────┴────────────────────────────────────────────────────────┘
;
; REP Prefixes:
; ┌──────────┬────────────────────────────────────────────────────────┐
; │ REP      │ Repeat RCX times                                       │
; │ REPE     │ Repeat while equal (ZF=1) and RCX > 0                  │
; │ REPNE    │ Repeat while not equal (ZF=0) and RCX > 0              │
; └──────────┴────────────────────────────────────────────────────────┘
;
; Addressing Modes for Arrays:
;   [base + index]           - 1-byte elements
;   [base + index*2]         - 2-byte elements (words)
;   [base + index*4]         - 4-byte elements (dwords)
;   [base + index*8]         - 8-byte elements (qwords)
;   [base + index*scale + disp] - Full addressing
;
; Performance Tips:
;   - Use REP MOVSQ for large block copies
;   - Use REP STOSQ for large block fills
;   - For small copies, manual loops may be faster
;   - Keep frequently accessed arrays in cache
;   - Align arrays to cache line boundaries (64 bytes)
;
; ============================================================================

