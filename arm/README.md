# ARM Assembly Programming Tutorial

## Overview

This directory contains comprehensive ARM assembly programming examples for both ARM64 (AArch64) and ARM32 (AArch32). Each file is extensively commented and demonstrates specific concepts.

## Prerequisites

- **Assembler**: GNU as (gas) - part of binutils
- **Linker**: ld (GNU linker)
- **System**: ARM64 (AArch64) or ARM32 with cross-compilation tools
- **Hardware**: ARM-based computer, Raspberry Pi, or QEMU emulator

## Installation

### For ARM64 (Native on ARM64 system)

```bash
# Install development tools
sudo apt-get install build-essential

# Verify
as --version
ld --version
```

### For ARM64 (Cross-compilation on x86_64)

```bash
# Install cross-compiler toolchain
sudo apt-get install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# Or use the GNU Arm toolchain
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/[version]/gcc-arm-[version]-x86_64-aarch64-none-linux-gnu.tar.xz
```

### For ARM32 (Cross-compilation)

```bash
# Install ARM32 cross-compiler
sudo apt-get install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf
```

### Using QEMU for Testing

```bash
# Install QEMU ARM emulator
sudo apt-get install qemu-user qemu-user-static

# Run ARM64 binaries
qemu-aarch64 ./program

# Run ARM32 binaries
qemu-arm ./program
```

## Building Examples

### ARM64 Assembly Files

```bash
# Basic build (native ARM64)
as -o filename.o filename.s
ld -o output filename.o
./output

# With debugging symbols
as -g -o filename.o filename.s
ld -o output filename.o

# Cross-compilation (on x86_64)
aarch64-linux-gnu-as -o filename.o filename.s
aarch64-linux-gnu-ld -o output filename.o
qemu-aarch64 ./output

# Example
as -o 01_hello_world_arm64.o 01_hello_world_arm64.s
ld -o hello 01_hello_world_arm64.o
./hello
```

### ARM32 Assembly Files

```bash
# Cross-compilation for ARM32
arm-linux-gnueabihf-as -o filename.o filename.s
arm-linux-gnueabihf-ld -o output filename.o
qemu-arm ./output
```

## File Structure

### Architecture Documentation

| File | Description |
|------|-------------|
| **00_ARCHITECTURE.md** | Comprehensive ARM architecture overview |

### ARM64 Examples

| File | Topics | Description |
|------|--------|-------------|
| **01_hello_world_arm64.s** | System calls, basic structure | First ARM64 program |
| **02_registers_and_data_arm64.s** | Registers, data types, operations | Working with ARM64 registers |
| **03_control_flow_arm64.s** | Branches, loops, conditionals | Control flow in ARM64 |
| **04_functions_and_stack_arm64.s** | Functions, AAPCS64, stack | Function calls and conventions |
| **05_neon_simd_arm64.s** | NEON, SIMD, vectorization | Vector operations for performance |

### ARM32 Examples

| File | Topics | Description |
|------|--------|-------------|
| **01_hello_world_arm32.s** | System calls, ARM32 basics | First ARM32 program |

## Topics Covered

### 1. **ARM Architecture Fundamentals**
- Register architecture (31 GPRs in ARM64, 16 in ARM32)
- Instruction encoding (fixed 32-bit)
- Load-store architecture
- Condition flags
- SIMD/NEON registers

### 2. **Data Operations**
- Moving data (mov, movz, movk)
- Arithmetic (add, sub, mul, madd, msub, udiv, sdiv)
- Logical operations (and, orr, eor, mvn, bic)
- Bit manipulation (lsl, lsr, asr, ror, ubfx, bfi)
- Zero register (XZR/WZR)

### 3. **Memory Access**
- Load/store instructions (ldr, str, ldrb, strb, etc.)
- Addressing modes (base, offset, pre/post-indexed)
- Load/store pair (ldp, stp)
- Memory barriers
- Alignment requirements

### 4. **Control Flow**
- Unconditional branches (b, br, bl, blr)
- Conditional branches (b.eq, b.ne, b.gt, b.lt, etc.)
- Compare and branch (cbz, cbnz)
- Test bit and branch (tbz, tbnz)
- Conditional select (csel, csinc, csinv, csneg)

### 5. **Functions and Stack**
- AAPCS64 calling convention
- Function prologue and epilogue
- Stack frame management
- Register preservation
- Recursive functions
- Link register (LR/X30)

### 6. **NEON SIMD**
- Vector registers (V0-V31)
- Packed operations (arithmetic, logical)
- Vector loads/stores
- Lane operations
- Reductions and broadcasts
- Vectorization techniques

### 7. **Advanced Topics**
- Atomic operations
- System registers
- Exception levels
- Memory ordering
- Performance optimization

## System Call Reference

### ARM64 Linux System Calls

| Number | Name | Arguments | Description |
|--------|------|-----------|-------------|
| 63 | read | fd, buf, count | Read from file |
| 64 | write | fd, buf, count | Write to file |
| 56 | openat | dirfd, pathname, flags, mode | Open file |
| 57 | close | fd | Close file |
| 93 | exit | status | Exit program |
| 222 | mmap | addr, length, prot, flags, fd, offset | Map memory |

### ARM32 Linux System Calls (EABI)

| Number | Name | Arguments | Description |
|--------|------|-----------|-------------|
| 3 | read | fd, buf, count | Read from file |
| 4 | write | fd, buf, count | Write to file |
| 5 | open | pathname, flags, mode | Open file |
| 6 | close | fd | Close file |
| 1 | exit | status | Exit program |

### Calling Convention

**ARM64:**
```
System Call Arguments:
  X8 - System call number
  X0 - 1st argument
  X1 - 2nd argument
  X2 - 3rd argument
  X3 - 4th argument
  X4 - 5th argument
  X5 - 6th argument

Instruction: svc #0
Return: X0 (negative = error)
```

**ARM32:**
```
System Call Arguments:
  R7 - System call number
  R0 - 1st argument
  R1 - 2nd argument
  R2 - 3rd argument
  R3 - 4th argument
  R4 - 5th argument
  R5 - 6th argument

Instruction: svc #0
Return: R0 (negative = error)
```

## Register Usage

### ARM64 Register Set

```
┌──────────┬────────────────────────────────────────────────┐
│ Register │ Usage / Convention                             │
├──────────┼────────────────────────────────────────────────┤
│ X0-X7    │ Argument/result registers (caller-saved)       │
│ X8       │ Indirect result location, syscall number       │
│ X9-X15   │ Temporary registers (caller-saved)             │
│ X16-X17  │ IP0, IP1 (intra-procedure-call temps)          │
│ X18      │ Platform register (reserved)                   │
│ X19-X28  │ Callee-saved registers                         │
│ X29/FP   │ Frame Pointer (callee-saved)                   │
│ X30/LR   │ Link Register (caller-saved)                   │
│ SP       │ Stack Pointer (must be preserved)              │
│ XZR      │ Zero register (reads as 0, writes ignored)     │
│ PC       │ Program Counter (not directly accessible)      │
└──────────┴────────────────────────────────────────────────┘
```

### ARM32 Register Set

```
┌──────────┬────────────────────────────────────────────────┐
│ Register │ Usage / Convention                             │
├──────────┼────────────────────────────────────────────────┤
│ R0-R3    │ Argument/result registers (caller-saved)       │
│ R4-R11   │ Callee-saved registers                         │
│ R12/IP   │ Intra-procedure-call scratch register          │
│ R13/SP   │ Stack Pointer                                  │
│ R14/LR   │ Link Register (return address)                 │
│ R15/PC   │ Program Counter                                │
│ CPSR     │ Current Program Status Register                │
└──────────┴────────────────────────────────────────────────┘
```

### NEON SIMD Registers

```
ARM64 NEON:
  V0-V31   - 128-bit SIMD/FP registers
  Access as: Vn.4s (4 floats), Vn.2d (2 doubles),
             Vn.16b (16 bytes), etc.

ARM32 NEON:
  Q0-Q15   - 128-bit SIMD registers
  D0-D31   - 64-bit SIMD registers
  S0-S31   - 32-bit FP registers
```

## Assembler Syntax (GNU as)

### Comments

```assembly
// Single-line comment (C++-style)
@ Single-line comment (ARM-style)
/* Multi-line
   comment */
```

### Instructions

```assembly
// ARM64 examples
mov     x0, #42              // Move immediate
add     x1, x2, x3           // x1 = x2 + x3
ldr     x0, [x1, #8]         // Load from memory
str     x0, [x1, #8]!        // Store with pre-increment

// ARM32 examples
mov     r0, #42              @ Move immediate
add     r1, r2, r3           @ r1 = r2 + r3
ldr     r0, [r1, #4]         @ Load from memory
str     r0, [r1, #4]!        @ Store with pre-increment
```

### Directives

```assembly
.global _start               // Export symbol
.section .data               // Data section
.section .text               // Code section
.align 4                     // Align to 16 bytes (2^4)
.ascii "string"              // ASCII string
.asciz "string"              // Null-terminated string
.byte 0xFF                   // 8-bit value
.hword 0xFFFF                // 16-bit value
.word 0xFFFFFFFF             // 32-bit value
.dword 0xFFFFFFFFFFFFFFFF    // 64-bit value
.float 3.14                  // 32-bit float
.double 2.718                // 64-bit double
.skip 64                     // Reserve 64 bytes
```

## Debugging

### Using GDB

```bash
# Compile with debug symbols
as -g -o program.o program.s
ld -o program program.o

# Debug
gdb ./program
(gdb) break _start
(gdb) run
(gdb) info registers
(gdb) x/10x $sp              # Examine stack
(gdb) stepi                  # Step one instruction
```

### Useful GDB Commands

```
info registers           - Show all registers
info registers x0        - Show specific register
x/10x $sp               - Examine 10 hex values at stack
x/10i $pc               - Disassemble 10 instructions
layout regs             - TUI mode with registers
layout asm              - TUI mode with assembly
```

### QEMU Debugging

```bash
# Run with debugging enabled
qemu-aarch64 -g 1234 ./program

# In another terminal
gdb-multiarch ./program
(gdb) target remote :1234
(gdb) continue
```

## Performance Tips

### 1. **Register Allocation**
- Use all 31 general-purpose registers (ARM64)
- Keep frequently used data in callee-saved registers (X19-X28)
- Minimize stack spills

### 2. **Memory Access**
- Align data naturally (4 bytes for words, 8 for doublewords)
- Use load/store pair (ldp/stp) when possible
- Prefer post-indexed addressing for sequential access
- Keep working set in cache

### 3. **Branch Optimization**
- Use cbz/cbnz instead of cmp + branch
- Use tbz/tbnz for bit tests
- Use csel for simple conditional moves
- Make branches predictable

### 4. **NEON SIMD**
- Process 4 floats or 2 doubles at once
- Keep vectors 16-byte aligned
- Use load/store with post-increment (ld1/st1)
- Avoid frequent scalar-vector conversions

### 5. **Instruction Selection**
- Use madd/msub for multiply-accumulate
- Use conditional select instead of branching
- Use shifts for multiplication/division by powers of 2
- Use zero register (XZR) when possible

## Common Patterns

### Loop Pattern (ARM64)

```assembly
    mov     x19, #0              // i = 0
loop_start:
    cmp     x19, #100
    b.ge    loop_end
    
    // Loop body
    
    add     x19, x19, #1
    b       loop_start
loop_end:
```

### Function Pattern (ARM64)

```assembly
function_name:
    // Prologue
    stp     x29, x30, [sp, #-32]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    
    // Function body
    
    // Epilogue
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret
```

## Resources

### Official Documentation
- **ARM Architecture Reference Manual (ARMv8)** 
  https://developer.arm.com/documentation/

- **ARM Compiler armasm User Guide**
  https://developer.arm.com/documentation/

- **Procedure Call Standard for ARM64 (AAPCS64)**
  https://github.com/ARM-software/abi-aa

### Tutorials and Guides
- **GNU Assembler Manual**: https://sourceware.org/binutils/docs/as/
- **ARM Assembly Basics**: https://azeria-labs.com/writing-arm-assembly-part-1/
- **NEON Programmer's Guide**: ARM Developer website

### Tools
- **GNU Binutils** - Assembler and linker
- **GDB** - GNU Debugger
- **QEMU** - ARM emulator
- **objdump** - Disassembler
- **Compiler Explorer** - Online assembly viewer

## Practice Exercises

### Beginner
1. Write a program that prints numbers 1-10
2. Implement string length function
3. Create array sum function
4. Write fibonacci sequence generator

### Intermediate
5. Implement string reversal in-place
6. Create binary search function
7. Write matrix multiplication (scalar)
8. Implement quicksort

### Advanced
9. Optimize matrix multiplication with NEON
10. Create atomic lock implementation
11. Implement memory allocator
12. Write optimized memcpy with NEON

## ARM64 vs ARM32 Key Differences

```
┌────────────────────┬─────────────────┬─────────────────┐
│ Feature            │ ARM64           │ ARM32           │
├────────────────────┼─────────────────┼─────────────────┤
│ Registers          │ 31 (X0-X30)     │ 16 (R0-R15)     │
│ Register Size      │ 64-bit          │ 32-bit          │
│ PC Access          │ No              │ Yes (R15)       │
│ Conditional Exec   │ Branches only   │ Most instrs     │
│ Zero Register      │ Yes (XZR)       │ No              │
│ System Calls       │ X8 + svc #0     │ R7 + svc #0     │
│ Stack Alignment    │ 16-byte         │ 8-byte          │
│ NEON               │ Standard        │ Optional        │
│ Instruction Size   │ 32-bit          │ 32-bit/16-bit   │
│ Barrel Shifter     │ Limited         │ Full            │
└────────────────────┴─────────────────┴─────────────────┘
```

## Common Mistakes

1. **Forgetting 16-byte stack alignment (ARM64)**
2. **Not preserving callee-saved registers**
3. **Using wrong syscall numbers for ARM64 vs ARM32**
4. **Confusing X and W registers in ARM64**
5. **Not using zero register (XZR) appropriately**
6. **Incorrect addressing mode syntax**
7. **Forgetting link register in non-leaf functions**
8. **Misaligned NEON loads/stores**

## Next Steps

After mastering ARM assembly:
- **Compiler optimization** - Understand how compilers work
- **Reverse engineering** - Binary analysis
- **Embedded systems** - Bare-metal programming
- **Mobile security** - ARM-based security research
- **Performance engineering** - System-level optimization

## Contributing

Improvements, corrections, and additional examples are welcome!

## License

These examples are provided for educational purposes. Use freely with attribution.

