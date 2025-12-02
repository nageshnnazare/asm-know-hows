# Assembly Programming Tutorial - Complete Overview

## Introduction

This comprehensive tutorial covers assembly programming for two major architectures:
- **x86_64** (AMD64/Intel 64) - Desktop, laptop, and server processors
- **ARM** (ARM64/AArch64 and ARM32/AArch32) - Mobile, embedded, and modern servers

## Directory Structure

```
/tmp/
├── x86_64/                    # x86_64 Assembly Tutorial
│   ├── 00_ARCHITECTURE.md     # Architecture overview
│   ├── 01_hello_world.asm     # Basic program
│   ├── 02_registers_and_data.asm
│   ├── 03_control_flow.asm
│   ├── 04_functions_and_stack.asm
│   ├── 05_strings_and_arrays.asm
│   ├── 06_macros_and_includes.asm
│   ├── 07_file_io.asm
│   ├── 08_simd_sse.asm
│   ├── 09_inline_asm_c.c     # Inline assembly in C
│   └── README.md              # x86_64 guide
│
└── arm/                       # ARM Assembly Tutorial
    ├── 00_ARCHITECTURE.md     # Architecture overview
    ├── 01_hello_world_arm64.s # ARM64 basic program
    ├── 01_hello_world_arm32.s # ARM32 basic program
    ├── 02_registers_and_data_arm64.s
    ├── 03_control_flow_arm64.s
    ├── 04_functions_and_stack_arm64.s
    ├── 05_neon_simd_arm64.s
    └── README.md              # ARM guide
```

## Architecture Comparison

### High-Level Overview

```
┌─────────────────┬──────────────────────┬──────────────────────┐
│ Feature         │ x86_64               │ ARM64                │
├─────────────────┼──────────────────────┼──────────────────────┤
│ Philosophy      │ CISC                 │ RISC                 │
│ Instruction Set │ Complex, variable    │ Simple, fixed-length │
│ Registers       │ 16 GPRs              │ 31 GPRs + Zero reg   │
│ Encoding        │ 1-15 bytes           │ Fixed 32-bit         │
│ Memory Access   │ Direct operations    │ Load-store only      │
│ Flags           │ RFLAGS register      │ PSTATE               │
│ Stack           │ Grows down           │ Grows down           │
│ Calling Conv    │ System V / MS x64    │ AAPCS64              │
│ SIMD            │ SSE/AVX (128-512bit) │ NEON (128-bit)       │
│ Endianness      │ Little               │ Bi-endian (usually little) │
│ Conditional     │ Limited              │ Branches + CSEL      │
└─────────────────┴──────────────────────┴──────────────────────┘
```

### Register Comparison

```
x86_64:                          ARM64:
┌────────────────────┐          ┌────────────────────┐
│ RAX - Accumulator  │          │ X0  - Arg/Result   │
│ RBX - Base         │          │ X1  - Arg/Result   │
│ RCX - Counter      │          │ X2-X7 - Args       │
│ RDX - Data         │          │ X8  - Ind result   │
│ RSI - Source Index │          │ X9-X15 - Temp      │
│ RDI - Dest Index   │          │ X16-X17 - IP       │
│ RBP - Base Pointer │          │ X18 - Platform     │
│ RSP - Stack Ptr    │          │ X19-X28 - Callee   │
│ R8-R15 - General   │          │ X29/FP - Frame Ptr │
│ RIP - Instr Ptr    │          │ X30/LR - Link Reg  │
│ XMM0-15 - SIMD     │          │ SP  - Stack Ptr    │
│ YMM0-15 - AVX      │          │ XZR - Zero reg     │
└────────────────────┘          │ V0-V31 - NEON SIMD │
                                └────────────────────┘
```

## Learning Path

### Week 1: Fundamentals

**Day 1-2: Architecture Understanding**
- Read `00_ARCHITECTURE.md` for both architectures
- Understand register layouts
- Learn memory models

**Day 3-4: First Programs**
- x86_64: `01_hello_world.asm`
- ARM: `01_hello_world_arm64.s`
- Understand system calls
- Build and run programs

**Day 5-7: Data Operations**
- x86_64: `02_registers_and_data.asm`
- ARM: `02_registers_and_data_arm64.s`
- Practice arithmetic operations
- Learn addressing modes

### Week 2: Control Flow

**Day 1-3: Branches and Loops**
- x86_64: `03_control_flow.asm`
- ARM: `03_control_flow_arm64.s`
- Implement various loop types
- Practice conditional execution

**Day 4-7: Functions**
- x86_64: `04_functions_and_stack.asm`
- ARM: `04_functions_and_stack_arm64.s`
- Understand calling conventions
- Write recursive functions

### Week 3: Intermediate Topics

**Day 1-3: Data Structures**
- x86_64: `05_strings_and_arrays.asm`
- String manipulation
- Array operations

**Day 4-5: Code Organization**
- x86_64: `06_macros_and_includes.asm`
- Write reusable code
- Use macros effectively

**Day 6-7: File I/O**
- x86_64: `07_file_io.asm`
- Read and write files
- Error handling

### Week 4: Advanced Topics

**Day 1-4: SIMD Programming**
- x86_64: `08_simd_sse.asm`
- ARM: `05_neon_simd_arm64.s`
- Vector operations
- Performance optimization

**Day 5-7: Integration**
- x86_64: `09_inline_asm_c.c`
- Inline assembly in C
- Mixed language programming

## Getting Started

### Quick Start (x86_64 on Linux)

```bash
cd /tmp/x86_64

# Build and run hello world
nasm -f elf64 01_hello_world.asm
ld -o hello 01_hello_world.o
./hello

# Build with debugging
nasm -f elf64 -g -F dwarf 01_hello_world.asm
ld -o hello 01_hello_world.o
gdb ./hello
```

### Quick Start (ARM64 on Linux)

```bash
cd /tmp/arm

# Build and run hello world (native ARM64)
as -o hello.o 01_hello_world_arm64.s
ld -o hello hello.o
./hello

# Cross-compile from x86_64
aarch64-linux-gnu-as -o hello.o 01_hello_world_arm64.s
aarch64-linux-gnu-ld -o hello hello.o
qemu-aarch64 ./hello
```

## Key Concepts by Architecture

### x86_64 Key Concepts

1. **CISC Philosophy**
   - Complex instructions
   - Variable-length encoding
   - Memory operands in instructions

2. **Register Usage**
   - RAX for return values and syscalls
   - RDI, RSI, RDX, RCX, R8, R9 for arguments
   - RBX, R12-R15 are callee-saved

3. **Addressing Modes**
   - SIB (Scale-Index-Base): `[base + index*scale + disp]`
   - Very flexible memory access

4. **SIMD**
   - SSE (128-bit XMM registers)
   - AVX (256-bit YMM registers)
   - AVX-512 (512-bit ZMM registers)

5. **Condition Codes**
   - Embedded in instruction name (not in separate field)
   - Examples: JE, JNE, JG, JL, etc.

### ARM Key Concepts

1. **RISC Philosophy**
   - Simple, regular instructions
   - Fixed-length encoding (32-bit)
   - Load-store architecture

2. **Register Usage**
   - X0-X7 for arguments and return values
   - X19-X28 are callee-saved
   - XZR always reads as zero
   - X30 (LR) holds return address

3. **Conditional Execution**
   - Conditional branches (B.EQ, B.NE, etc.)
   - Conditional select (CSEL) - no branching!
   - Compare and branch (CBZ, CBNZ)

4. **NEON SIMD**
   - 128-bit V registers (V0-V31)
   - Notation: v0.4s (4 singles), v0.2d (2 doubles)
   - Standard in ARM64

5. **Zero Register**
   - XZR/WZR always reads as zero
   - Useful for comparisons and clearing memory

## System Call Differences

### x86_64 Linux

```nasm
mov     rax, 1              ; sys_write
mov     rdi, 1              ; stdout
mov     rsi, msg            ; buffer
mov     rdx, len            ; length
syscall                     ; invoke
```

### ARM64 Linux

```assembly
mov     x8, #64             // sys_write
mov     x0, #1              // stdout
ldr     x1, =msg            // buffer
mov     x2, #len            // length
svc     #0                  // invoke
```

## Performance Considerations

### x86_64 Optimization Tips

1. **Use all 16 registers** - Don't leave R8-R15 unused
2. **Align data** - 16-byte alignment for SSE, 32 for AVX
3. **Use LEA** - For address calculation and arithmetic
4. **SIMD everything** - SSE/AVX for data-parallel code
5. **Avoid partial register writes** - Can cause stalls
6. **Branch prediction** - Make branches predictable

### ARM Optimization Tips

1. **Use all 31 registers** - Plenty of registers available
2. **Load/store pairs** - Use LDP/STP (more efficient)
3. **Post-indexed addressing** - For sequential access
4. **CSEL over branches** - Avoid branch mispredictions
5. **NEON for parallelism** - Process 4 floats at once
6. **Align to 16 bytes** - For NEON operations

## Common Pitfalls

### x86_64

- ✗ Forgetting to clear RDX before division
- ✗ Not maintaining 16-byte stack alignment
- ✗ Using unaligned SSE loads when alignment matters
- ✗ Incorrect clobber lists in inline assembly
- ✗ Not preserving callee-saved registers

### ARM

- ✗ Forgetting 16-byte stack alignment (mandatory!)
- ✗ Confusing X (64-bit) and W (32-bit) registers
- ✗ Using wrong syscall numbers (different from x86_64)
- ✗ Not using XZR when appropriate
- ✗ Forgetting to save link register (X30)

## Tools and Resources

### Assemblers

```
x86_64:
  - NASM (Intel syntax) ✓
  - GNU as (AT&T syntax)
  - MASM (Windows)

ARM:
  - GNU as (ARM syntax) ✓
  - armasm (ARM Compiler)
```

### Debuggers

```
- GDB (GNU Debugger) - Both architectures
- LLDB - Both architectures
- radare2 - Reverse engineering
- IDA Pro - Commercial disassembler
```

### Emulators

```
- QEMU - ARM emulation on x86_64
- Bochs - x86 emulation
- Unicorn - CPU emulator framework
```

### Online Resources

- **Intel SDM**: Official x86_64 reference
- **ARM ARM**: ARM Architecture Reference Manual
- **Compiler Explorer**: See compiler output
- **Agner Fog's guides**: Optimization manuals
- **OSDev Wiki**: OS development resources

## Projects to Build

### Beginner Projects
1. Calculator program
2. String manipulation library
3. Simple file viewer
4. Number base converter

### Intermediate Projects
5. Custom printf implementation
6. Sorting algorithm comparison
7. Simple memory allocator
8. Text file parser

### Advanced Projects
9. Cryptographic functions (AES, SHA)
10. Image processing with SIMD
11. Simple VM/interpreter
12. JIT compiler basics

## Testing Your Knowledge

### Self-Assessment Questions

**After Week 1:**
- Can you explain the difference between CISC and RISC?
- Do you understand register calling conventions?
- Can you write a simple program that prints output?

**After Week 2:**
- Can you implement all common loop types?
- Do you understand function call mechanics?
- Can you write recursive functions?

**After Week 3:**
- Can you manipulate strings and arrays?
- Do you understand memory addressing modes?
- Can you handle file I/O?

**After Week 4:**
- Can you use SIMD for vectorization?
- Do you understand optimization techniques?
- Can you integrate assembly with C?

## Next Steps

After completing this tutorial:

1. **Operating Systems**
   - Learn OS internals
   - Study kernel code
   - Write device drivers

2. **Compiler Design**
   - Understand code generation
   - Study optimization passes
   - Build a simple compiler

3. **Reverse Engineering**
   - Learn disassembly
   - Study malware analysis
   - Practice CTF challenges

4. **Performance Engineering**
   - Profile real applications
   - Optimize hot paths
   - Study microarchitecture

5. **Embedded Systems**
   - Bare-metal programming
   - ARM Cortex-M development
   - Real-time systems

## Contributing

Found an error? Have an improvement? Contributions welcome!

## Acknowledgments

These tutorials are designed to provide comprehensive, practical knowledge of assembly programming for modern architectures. The examples progress from fundamental concepts to advanced techniques, with extensive comments explaining every aspect.

## License

Educational use permitted with attribution.

---

**Happy Assembly Programming!** 🚀

Remember: Assembly is a superpower. Use it wisely to:
- Understand how computers work at the lowest level
- Write performance-critical code
- Debug complex issues
- Reverse engineer binaries
- Build operating systems and compilers

The journey from high-level languages to assembly is one of the most enlightening paths in computer science. Enjoy the ride!

