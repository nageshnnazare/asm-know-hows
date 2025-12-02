# x86_64 Assembly Programming Tutorial

## Overview

This directory contains comprehensive x86_64 assembly programming examples, from basic to advanced topics. Each file is extensively commented and demonstrates specific concepts.

## Prerequisites

- **Assembler**: NASM (Netwide Assembler)
- **Linker**: ld (GNU linker)
- **System**: Linux x86_64
- **Optional**: GCC for C inline assembly examples

## Installation

```bash
# Install NASM
sudo apt-get install nasm    # Debian/Ubuntu
sudo yum install nasm        # RHEL/CentOS
sudo pacman -S nasm          # Arch

# Install development tools
sudo apt-get install build-essential
```

## Building Examples

### Assembly Files (.asm)

```bash
# Basic build
nasm -f elf64 filename.asm && ld -o output filename.o

# With debugging symbols
nasm -f elf64 -g -F dwarf filename.asm && ld -o output filename.o

# Example
nasm -f elf64 01_hello_world.asm && ld -o hello 01_hello_world.o
./hello
```

### C Files with Inline Assembly (.c)

```bash
gcc -O2 filename.c -o output
./output
```

## File Structure

### Basics (01-04)

| File | Topics | Description |
|------|--------|-------------|
| **00_ARCHITECTURE.md** | Architecture | Comprehensive x86_64 architecture documentation |
| **01_hello_world.asm** | System calls, program structure | First assembly program |
| **02_registers_and_data.asm** | Registers, data types, arithmetic | Working with registers and basic operations |
| **03_control_flow.asm** | Jumps, loops, conditionals | Control flow structures |
| **04_functions_and_stack.asm** | Functions, stack, calling convention | Function calls and stack management |

### Intermediate (05-08)

| File | Topics | Description |
|------|--------|-------------|
| **05_strings_and_arrays.asm** | String operations, arrays | String manipulation and array access |
| **06_macros_and_includes.asm** | Macros, conditional assembly | Code organization with macros |
| **07_file_io.asm** | File operations, error handling | Reading and writing files |
| **08_simd_sse.asm** | SIMD, SSE/AVX, vectorization | Vector operations for performance |

### Advanced (09-10)

| File | Topics | Description |
|------|--------|-------------|
| **09_inline_asm_c.c** | Inline assembly (AT&T syntax), C integration | Using assembly in C programs (AT&T syntax) |
| **10_inline_asm_intel.c** | Inline assembly (Intel syntax) | Same examples using Intel syntax (destination first) |

## Topics Covered

### 1. **Architecture Fundamentals**
- Register architecture (16 GPRs, RFLAGS, segment registers)
- Memory addressing modes
- Instruction encoding (REX prefix, ModR/M, SIB)
- Cache hierarchy
- Virtual memory and paging

### 2. **Data Operations**
- Moving data (mov, lea, xchg)
- Arithmetic (add, sub, mul, div)
- Logical operations (and, or, xor, not)
- Bit manipulation (shl, shr, sar, rol, ror)
- Type conversion and extension

### 3. **Control Flow**
- Unconditional jumps (jmp, call, ret)
- Conditional jumps (je, jne, jg, jl, etc.)
- Loops (loop, rep, conditional jumps)
- Switch/case patterns
- Conditional moves (cmov)

### 4. **Functions and Stack**
- Calling conventions (System V AMD64 ABI)
- Function prologue and epilogue
- Local variables and parameters
- Register preservation
- Recursive functions

### 5. **String Operations**
- String instructions (movs, stos, lods, scas, cmps)
- REP prefixes
- Direction flag (DF)
- String manipulation functions

### 6. **Arrays and Memory**
- Array indexing
- Scaled addressing (SIB)
- Multi-dimensional arrays
- Structure access
- Memory alignment

### 7. **File I/O**
- System calls (open, read, write, close)
- File descriptors
- Error handling
- File copying and manipulation

### 8. **SIMD Programming**
- XMM registers
- SSE/AVX instructions
- Packed operations
- Vector arithmetic
- Horizontal operations

### 9. **Advanced Topics**
- Inline assembly in C
- Atomic operations
- CPU identification (CPUID)
- Performance counters (RDTSC)
- Memory barriers

## System Call Reference

### Common System Calls (x86_64 Linux)

| Number | Name | Arguments | Description |
|--------|------|-----------|-------------|
| 0 | read | fd, buf, count | Read from file |
| 1 | write | fd, buf, count | Write to file |
| 2 | open | filename, flags, mode | Open file |
| 3 | close | fd | Close file |
| 8 | lseek | fd, offset, whence | Seek in file |
| 9 | mmap | addr, length, prot, flags, fd, offset | Map memory |
| 60 | exit | status | Exit program |

### Calling Convention

```
System Call Arguments (System V AMD64):
  RAX - System call number
  RDI - 1st argument
  RSI - 2nd argument
  RDX - 3rd argument
  R10 - 4th argument
  R8  - 5th argument
  R9  - 6th argument

Return: RAX (negative = error)
```

## Register Usage

### General Purpose Registers

```
┌──────────┬────────────────────────────────────────────────┐
│ Register │ Usage / Convention                             │
├──────────┼────────────────────────────────────────────────┤
│ RAX      │ Accumulator, syscall number, return value      │
│ RBX      │ Base register (callee-saved)                   │
│ RCX      │ Counter (caller-saved)                         │
│ RDX      │ Data register (caller-saved)                   │
│ RSI      │ Source index (caller-saved, 2nd arg)           │
│ RDI      │ Destination index (caller-saved, 1st arg)      │
│ RBP      │ Base pointer (callee-saved, frame pointer)     │
│ RSP      │ Stack pointer (must be preserved)              │
│ R8-R9    │ Additional arguments (caller-saved)            │
│ R10-R11  │ Temporary (caller-saved)                       │
│ R12-R15  │ General purpose (callee-saved)                 │
└──────────┴────────────────────────────────────────────────┘
```

### SIMD Registers

```
SSE:  XMM0-XMM15 (128-bit)
AVX:  YMM0-YMM15 (256-bit, includes XMM)
AVX-512: ZMM0-ZMM31 (512-bit, includes YMM)
```

## Assembler Syntax

### Intel Syntax (NASM)

```nasm
; Destination first, source second
mov rax, rbx              ; rax = rbx
add rax, 10               ; rax += 10
mov rax, [rbx + 8]        ; rax = memory[rbx + 8]
```

### AT&T Syntax (GAS)

```gas
# Source first, destination second
movq %rbx, %rax           # rax = rbx
addq $10, %rax            # rax += 10
movq 8(%rbx), %rax        # rax = memory[rbx + 8]
```

## Debugging

### Using GDB

```bash
# Compile with debug symbols
nasm -f elf64 -g -F dwarf program.asm
ld -o program program.o

# Debug
gdb ./program
(gdb) break _start
(gdb) run
(gdb) info registers
(gdb) x/10x $rsp          # Examine stack
(gdb) stepi               # Step one instruction
```

### Useful GDB Commands

```
info registers        - Show all registers
info registers rax    - Show specific register
x/10x $rsp           - Examine 10 hex values at stack
x/10i $rip           - Disassemble 10 instructions
layout regs          - TUI mode with registers
layout asm           - TUI mode with assembly
```

## Performance Tips

### 1. **Register Allocation**
- Use all 16 general-purpose registers
- Keep frequently used data in registers
- Follow calling convention for register preservation

### 2. **Memory Access**
- Align data to cache line boundaries (64 bytes)
- Use sequential access patterns
- Minimize cache misses
- Prefetch data when access pattern is predictable

### 3. **Branch Optimization**
- Make branches predictable
- Use conditional moves (CMOV) for simple conditions
- Place likely path first
- Minimize branches in hot loops

### 4. **SIMD Usage**
- Use SSE/AVX for data-parallel operations
- Process multiple elements per instruction
- Keep data aligned (16/32 bytes)
- Use horizontal operations sparingly

### 5. **Instruction Selection**
- Use LEA for address calculation and arithmetic
- Prefer shifts over multiplication by powers of 2
- Use XOR to clear registers (xor rax, rax)
- Avoid expensive instructions (div, sqrt) in hot paths

### 6. **Loop Optimization**
- Unroll loops to reduce branch overhead
- Use pointer arithmetic instead of indexing
- Minimize loop-carried dependencies
- Keep loop bodies small

## Common Patterns

### Loop Pattern

```nasm
    xor     rcx, rcx            ; i = 0
loop_start:
    cmp     rcx, 100
    jge     loop_end
    
    ; Loop body
    
    inc     rcx
    jmp     loop_start
loop_end:
```

### Function Pattern

```nasm
function_name:
    ; Prologue
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32             ; Allocate locals
    
    ; Save callee-saved registers
    push    rbx
    
    ; Function body
    
    ; Restore callee-saved registers
    pop     rbx
    
    ; Epilogue
    mov     rsp, rbp
    pop     rbp
    ret
```

### Error Handling

```nasm
    ; System call
    mov     rax, 2              ; sys_open
    mov     rdi, filename
    mov     rsi, 0              ; O_RDONLY
    syscall
    
    ; Check for error
    cmp     rax, 0
    jl      error_handler       ; Negative = error
    
    ; Success path
    mov     [fd], rax
    jmp     continue
    
error_handler:
    ; Handle error
    
continue:
```

## Resources

### Official Documentation
- **Intel 64 and IA-32 Architectures Software Developer Manuals**
  https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html

- **AMD64 Architecture Programmer's Manual**
  https://developer.amd.com/resources/developer-guides-manuals/

- **System V AMD64 ABI**
  https://gitlab.com/x86-psABIs/x86-64-ABI

### Tutorials and Guides
- **NASM Documentation**: https://www.nasm.us/docs.php
- **Linux System Call Table**: https://filippo.io/linux-syscall-table/
- **x86-64 Instruction Reference**: https://www.felixcloutier.com/x86/

### Tools
- **NASM**: Netwide Assembler
- **GDB**: GNU Debugger
- **objdump**: Disassembler
- **perf**: Linux profiling tool
- **Intel XED**: Instruction encoder/decoder

## Practice Exercises

### Beginner
1. Write a program that prints numbers 1-10
2. Implement string length function
3. Create array sum function
4. Write fibonacci sequence generator

### Intermediate
5. Implement string reversal in-place
6. Create binary search function
7. Write matrix multiplication
8. Implement quicksort

### Advanced
9. Optimize loop with SIMD
10. Create thread-safe atomic operations
11. Implement memory allocator
12. Write optimized string matching (Boyer-Moore)

## Common Mistakes

1. **Not checking system call return values**
2. **Incorrect stack alignment (must be 16-byte aligned)**
3. **Forgetting to preserve callee-saved registers**
4. **Not clearing direction flag after using string instructions**
5. **Using unaligned loads with instructions requiring alignment**
6. **Mixing up signed/unsigned comparisons**
7. **Not clearing RDX before division**
8. **Incorrect clobber lists in inline assembly**

## Next Steps

After mastering x86_64, consider:
- **ARM assembly** - Mobile and embedded systems
- **Compiler optimization** - Understanding how compilers work
- **Reverse engineering** - Binary analysis and security
- **Operating systems** - Kernel development
- **Performance engineering** - System-level optimization

## Contributing

Feel free to submit improvements, corrections, or additional examples!

## License

These examples are provided for educational purposes. Use freely with attribution.

