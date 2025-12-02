; ============================================================================
; File: 07_file_io.asm
; Description: File I/O operations using system calls
; Topics: open, read, write, close, file descriptors, error handling
; Assembler: NASM
; Build: nasm -f elf64 07_file_io.asm && ld -o 07_file_io 07_file_io.o
; Run: ./07_file_io
; ============================================================================

global _start

; System call numbers (x86_64 Linux)
%define SYS_READ    0
%define SYS_WRITE   1
%define SYS_OPEN    2
%define SYS_CLOSE   3
%define SYS_CREAT   85
%define SYS_EXIT    60

; File access modes (open flags)
%define O_RDONLY    0
%define O_WRONLY    1
%define O_RDWR      2
%define O_CREAT     64
%define O_TRUNC     512
%define O_APPEND    1024

; File permissions (mode)
%define S_IRUSR     0400    ; User read
%define S_IWUSR     0200    ; User write
%define S_IXUSR     0100    ; User execute
%define S_IRWXU     0700    ; User rwx

%define STDIN       0
%define STDOUT      1
%define STDERR      2

section .data
    ; File names
    input_file:     db "input.txt", 0
    output_file:    db "output.txt", 0
    test_file:      db "test.txt", 0
    
    ; Messages
    msg_create:     db "Creating file...", 0x0a
    msg_create_len: equ $ - msg_create
    
    msg_write:      db "Writing to file...", 0x0a
    msg_write_len:  equ $ - msg_write
    
    msg_read:       db "Reading from file...", 0x0a
    msg_read_len:   equ $ - msg_read
    
    msg_error:      db "Error occurred!", 0x0a
    msg_error_len:  equ $ - msg_error
    
    msg_success:    db "Success!", 0x0a
    msg_success_len: equ $ - msg_success
    
    ; Data to write
    write_data:     db "Hello, File I/O!", 0x0a, \
                       "This is a test of file operations.", 0x0a, \
                       "Assembly is powerful!", 0x0a
    write_data_len: equ $ - write_data

section .bss
    read_buffer:    resb 1024       ; Buffer for reading
    file_fd:        resq 1          ; File descriptor storage

section .text

_start:
    ; ========================================================================
    ; CREATING A FILE
    ; ========================================================================
    
    ; Print message
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, msg_create
    mov     rdx, msg_create_len
    syscall
    
    ; Create/Open file for writing (O_WRONLY | O_CREAT | O_TRUNC)
    ; syscall: open(filename, flags, mode)
    mov     rax, SYS_OPEN
    mov     rdi, test_file          ; Filename
    mov     rsi, O_WRONLY | O_CREAT | O_TRUNC  ; Flags
    mov     rdx, 0644o              ; Permissions: rw-r--r--
    syscall
    
    ; Check for error
    cmp     rax, 0
    jl      error_handler           ; Negative return = error
    
    ; Save file descriptor
    mov     [file_fd], rax
    
    ; ========================================================================
    ; WRITING TO FILE
    ; ========================================================================
    
    ; Print message
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, msg_write
    mov     rdx, msg_write_len
    syscall
    
    ; Write data to file
    ; syscall: write(fd, buffer, count)
    mov     rax, SYS_WRITE
    mov     rdi, [file_fd]          ; File descriptor
    mov     rsi, write_data         ; Buffer to write
    mov     rdx, write_data_len     ; Number of bytes
    syscall
    
    ; Check for error
    cmp     rax, 0
    jl      error_handler
    
    ; ========================================================================
    ; CLOSING FILE
    ; ========================================================================
    
    ; Close file
    ; syscall: close(fd)
    mov     rax, SYS_CLOSE
    mov     rdi, [file_fd]
    syscall
    
    ; ========================================================================
    ; OPENING FILE FOR READING
    ; ========================================================================
    
    ; Print message
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, msg_read
    mov     rdx, msg_read_len
    syscall
    
    ; Open file for reading
    mov     rax, SYS_OPEN
    mov     rdi, test_file
    mov     rsi, O_RDONLY           ; Read-only mode
    mov     rdx, 0                  ; Mode not needed for reading
    syscall
    
    ; Check for error
    cmp     rax, 0
    jl      error_handler
    
    mov     [file_fd], rax
    
    ; ========================================================================
    ; READING FROM FILE
    ; ========================================================================
    
    ; Read data from file
    ; syscall: read(fd, buffer, count)
    mov     rax, SYS_READ
    mov     rdi, [file_fd]          ; File descriptor
    mov     rsi, read_buffer        ; Buffer to read into
    mov     rdx, 1024               ; Maximum bytes to read
    syscall
    
    ; Check for error
    cmp     rax, 0
    jl      error_handler
    
    ; RAX contains number of bytes read
    mov     r12, rax                ; Save bytes read
    
    ; ========================================================================
    ; DISPLAYING READ DATA
    ; ========================================================================
    
    ; Write read data to stdout
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, read_buffer
    mov     rdx, r12                ; Number of bytes read
    syscall
    
    ; Close file
    mov     rax, SYS_CLOSE
    mov     rdi, [file_fd]
    syscall
    
    ; ========================================================================
    ; APPENDING TO FILE
    ; ========================================================================
    
    ; Open file in append mode
    mov     rax, SYS_OPEN
    mov     rdi, test_file
    mov     rsi, O_WRONLY | O_APPEND  ; Append mode
    mov     rdx, 0
    syscall
    
    cmp     rax, 0
    jl      error_handler
    
    mov     [file_fd], rax
    
    ; Append additional data
    mov     rax, SYS_WRITE
    mov     rdi, [file_fd]
    mov     rsi, msg_success
    mov     rdx, msg_success_len
    syscall
    
    ; Close file
    mov     rax, SYS_CLOSE
    mov     rdi, [file_fd]
    syscall
    
    ; ========================================================================
    ; READ/WRITE LOOP EXAMPLE
    ; ========================================================================
    
    ; Copy file contents (read and write in loop)
    call    copy_file
    
    ; ========================================================================
    ; SUCCESS - EXIT
    ; ========================================================================
    
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, msg_success
    mov     rdx, msg_success_len
    syscall
    
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

; ============================================================================
; ERROR HANDLER
; ============================================================================
error_handler:
    mov     rax, SYS_WRITE
    mov     rdi, STDERR
    mov     rsi, msg_error
    mov     rdx, msg_error_len
    syscall
    
    mov     rax, SYS_EXIT
    mov     rdi, 1                  ; Exit with error code
    syscall

; ============================================================================
; FUNCTION: copy_file
; Description: Copy input.txt to output.txt
; ============================================================================
copy_file:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16                 ; Space for local variables
    
    ; Open source file
    mov     rax, SYS_OPEN
    mov     rdi, input_file
    mov     rsi, O_RDONLY
    xor     rdx, rdx
    syscall
    
    cmp     rax, 0
    jl      .error
    
    mov     [rbp - 8], rax          ; Save source fd
    
    ; Open/create destination file
    mov     rax, SYS_OPEN
    mov     rdi, output_file
    mov     rsi, O_WRONLY | O_CREAT | O_TRUNC
    mov     rdx, 0644o
    syscall
    
    cmp     rax, 0
    jl      .close_src
    
    mov     [rbp - 16], rax         ; Save dest fd
    
.read_loop:
    ; Read from source
    mov     rax, SYS_READ
    mov     rdi, [rbp - 8]          ; Source fd
    mov     rsi, read_buffer
    mov     rdx, 1024
    syscall
    
    cmp     rax, 0
    jle     .done                   ; EOF or error
    
    mov     r12, rax                ; Save bytes read
    
    ; Write to destination
    mov     rax, SYS_WRITE
    mov     rdi, [rbp - 16]         ; Dest fd
    mov     rsi, read_buffer
    mov     rdx, r12
    syscall
    
    cmp     rax, 0
    jl      .done
    
    jmp     .read_loop
    
.done:
    ; Close destination
    mov     rax, SYS_CLOSE
    mov     rdi, [rbp - 16]
    syscall
    
.close_src:
    ; Close source
    mov     rax, SYS_CLOSE
    mov     rdi, [rbp - 8]
    syscall
    
.error:
    mov     rsp, rbp
    pop     rbp
    ret

; ============================================================================
; FUNCTION: file_size
; Description: Get size of a file
; Arguments: RDI = filename
; Returns: RAX = file size (-1 on error)
; Note: Uses lseek to find file size
; ============================================================================
%define SYS_LSEEK   8
%define SEEK_END    2

file_size:
    push    rbp
    mov     rbp, rsp
    push    rbx
    
    ; Open file
    mov     rax, SYS_OPEN
    ; RDI already contains filename
    mov     rsi, O_RDONLY
    xor     rdx, rdx
    syscall
    
    cmp     rax, 0
    jl      .error
    
    mov     rbx, rax                ; Save fd
    
    ; Seek to end
    mov     rax, SYS_LSEEK
    mov     rdi, rbx                ; fd
    xor     rsi, rsi                ; offset = 0
    mov     rdx, SEEK_END           ; whence = SEEK_END
    syscall
    
    ; RAX now contains file size
    push    rax                     ; Save size
    
    ; Close file
    mov     rax, SYS_CLOSE
    mov     rdi, rbx
    syscall
    
    pop     rax                     ; Restore size
    jmp     .done
    
.error:
    mov     rax, -1
    
.done:
    pop     rbx
    pop     rbp
    ret

; ============================================================================
; FUNCTION: read_entire_file
; Description: Read entire file into buffer
; Arguments: RDI = filename, RSI = buffer, RDX = max_size
; Returns: RAX = bytes read (-1 on error)
; ============================================================================
read_entire_file:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    
    mov     r12, rsi                ; Save buffer
    mov     r13, rdx                ; Save max size
    
    ; Open file
    mov     rax, SYS_OPEN
    ; RDI already contains filename
    mov     rsi, O_RDONLY
    xor     rdx, rdx
    syscall
    
    cmp     rax, 0
    jl      .error
    
    mov     rbx, rax                ; Save fd
    
    ; Read file
    mov     rax, SYS_READ
    mov     rdi, rbx                ; fd
    mov     rsi, r12                ; buffer
    mov     rdx, r13                ; max size
    syscall
    
    push    rax                     ; Save bytes read
    
    ; Close file
    mov     rax, SYS_CLOSE
    mov     rdi, rbx
    syscall
    
    pop     rax                     ; Restore bytes read
    jmp     .done
    
.error:
    mov     rax, -1
    
.done:
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ============================================================================
; FUNCTION: write_entire_file
; Description: Write buffer to file
; Arguments: RDI = filename, RSI = buffer, RDX = size
; Returns: RAX = 0 on success, -1 on error
; ============================================================================
write_entire_file:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    
    mov     r12, rsi                ; Save buffer
    mov     r13, rdx                ; Save size
    
    ; Create/open file
    mov     rax, SYS_OPEN
    ; RDI already contains filename
    mov     rsi, O_WRONLY | O_CREAT | O_TRUNC
    mov     rdx, 0644o
    syscall
    
    cmp     rax, 0
    jl      .error
    
    mov     rbx, rax                ; Save fd
    
    ; Write to file
    mov     rax, SYS_WRITE
    mov     rdi, rbx                ; fd
    mov     rsi, r12                ; buffer
    mov     rdx, r13                ; size
    syscall
    
    cmp     rax, 0
    jl      .close_error
    
    ; Close file
    mov     rax, SYS_CLOSE
    mov     rdi, rbx
    syscall
    
    xor     rax, rax                ; Success
    jmp     .done
    
.close_error:
    ; Close file even on error
    push    rax
    mov     rax, SYS_CLOSE
    mov     rdi, rbx
    syscall
    pop     rax
    
.error:
    mov     rax, -1
    
.done:
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ============================================================================
; NOTES: File I/O System Calls
; ============================================================================
;
; System Calls:
; ┌──────────┬────────────────────────────────────────────────────────┐
; │ open     │ rax=2, rdi=filename, rsi=flags, rdx=mode              │
; │ read     │ rax=0, rdi=fd, rsi=buffer, rdx=count                  │
; │ write    │ rax=1, rdi=fd, rsi=buffer, rdx=count                  │
; │ close    │ rax=3, rdi=fd                                         │
; │ lseek    │ rax=8, rdi=fd, rsi=offset, rdx=whence                 │
; │ creat    │ rax=85, rdi=filename, rsi=mode                        │
; └──────────┴────────────────────────────────────────────────────────┘
;
; Open Flags (can be OR'd together):
;   O_RDONLY    (0)     - Read only
;   O_WRONLY    (1)     - Write only
;   O_RDWR      (2)     - Read and write
;   O_CREAT     (64)    - Create if doesn't exist
;   O_TRUNC     (512)   - Truncate to zero length
;   O_APPEND    (1024)  - Append mode
;   O_EXCL      (128)   - Fail if file exists (with O_CREAT)
;
; File Permissions (octal):
;   0644 = rw-r--r-- (owner: rw, group: r, others: r)
;   0755 = rwxr-xr-x (owner: rwx, group: rx, others: rx)
;   0600 = rw------- (owner: rw, group: none, others: none)
;
; Return Values:
;   open:  Returns file descriptor (>= 0) on success, -1 on error
;   read:  Returns bytes read (0 = EOF, -1 = error)
;   write: Returns bytes written (-1 = error)
;   close: Returns 0 on success, -1 on error
;
; Error Codes (negative values in RAX):
;   -1  (EPERM)      - Operation not permitted
;   -2  (ENOENT)     - No such file or directory
;   -9  (EBADF)      - Bad file descriptor
;   -13 (EACCES)     - Permission denied
;   -17 (EEXIST)     - File exists
;   -28 (ENOSPC)     - No space left on device
;
; Best Practices:
;   1. Always check return values for errors
;   2. Close files when done
;   3. Use appropriate buffer sizes (4KB or multiples)
;   4. Handle partial reads/writes in loops
;   5. Set appropriate file permissions
;   6. Use error handling consistently
;
; ============================================================================

