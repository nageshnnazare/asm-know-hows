# x86_64 Architecture Overview

## Table of Contents
1. [Introduction](#introduction)
2. [Historical Context](#historical-context)
3. [Register Architecture](#register-architecture)
4. [Memory Architecture](#memory-architecture)
5. [Instruction Set Architecture](#instruction-set-architecture)
6. [Calling Conventions](#calling-conventions)
7. [System Architecture](#system-architecture)
8. [Performance Considerations](#performance-considerations)

---

## Introduction

x86_64 (also known as AMD64 or Intel 64) is the 64-bit extension of the x86 instruction set architecture. It was developed by AMD and later adopted by Intel. The architecture provides:

- **64-bit registers** and addressing
- **Backward compatibility** with 32-bit and 16-bit code
- **Extended register set** (16 general-purpose registers instead of 8)
- **Improved performance** through larger address space and more registers
- **Enhanced instruction set** with SSE, AVX, and other extensions

---

## Historical Context

```
Evolution Timeline:
┌─────────────────────────────────────────────────────────────────┐
│ 1978: 8086 (16-bit) → 8 registers, 1MB addressable memory       │
│   ↓                                                             │
│ 1985: 80386 (32-bit) → Extended to 32-bit, 4GB addressable      │
│   ↓                                                             │
│ 2003: AMD64 (64-bit) → 64-bit extension, 16 registers           │
│   ↓                                                             │
│ 2004: Intel 64 → Intel's implementation of x86_64               │
│   ↓                                                             │
│ Present: Modern x86_64 with AVX-512, SGX, etc.                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Register Architecture

### General Purpose Registers (GPRs)

x86_64 has 16 general-purpose 64-bit registers. Each can be accessed in different sizes:

```
64-bit    32-bit   16-bit   8-bit(high)  8-bit(low)
┌────────────────────────────────────────────────────┐
│ RAX      EAX      AX       AH           AL         │  Accumulator
│ RBX      EBX      BX       BH           BL         │  Base
│ RCX      ECX      CX       CH           CL         │  Counter
│ RDX      EDX      DX       DH           DL         │  Data
│ RSI      ESI      SI       -            SIL        │  Source Index
│ RDI      EDI      DI       -            DIL        │  Destination Index
│ RBP      EBP      BP       -            BPL        │  Base Pointer
│ RSP      ESP      SP       -            SPL        │  Stack Pointer
│ R8       R8D      R8W      -            R8B        │  General Purpose
│ R9       R9D      R9W      -            R9B        │  General Purpose
│ R10      R10D     R10W     -            R10B       │  General Purpose
│ R11      R11D     R11W     -            R11B       │  General Purpose
│ R12      R12D     R12W     -            R12B       │  General Purpose
│ R13      R13D     R13W     -            R13B       │  General Purpose
│ R14      R14D     R14W     -            R14B       │  General Purpose
│ R15      R15D     R15W     -            R15B       │  General Purpose
└────────────────────────────────────────────────────┘

Register Bit Layout (RAX example):
┌─────────────────────────────────────────────────────────────────┐
│ 63                            32│31             16│15    8│7   0│
│ ├───────────────────────────────┼─────────────────┼───────┼─────┤
│                 RAX (64-bit)                                    │
│                                 │      EAX (32-bit)             │
│                                 │                 │      AX     │
│                                 │                 │    AH │ AL  │
└─────────────────────────────────────────────────────────────────┘
```

### Special Purpose Registers

```
┌──────────────────────────────────────────────────────────────┐
│ RIP    - Instruction Pointer (Program Counter)               │
│ RFLAGS - Flags Register (Status and Control flags)           │
│ RSP    - Stack Pointer (Points to top of stack)              │
│ RBP    - Base Pointer (Frame pointer for function calls)     │
└──────────────────────────────────────────────────────────────┘
```

### RFLAGS Register Layout

```
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│ 63  │ ... │ 11  │ 10  │  9  │  8  │  7  │  6  │  4  │  2  │  0  │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│     │     │ OF  │ DF  │ IF  │ TF  │ SF  │ ZF  │ AF  │ PF  │ CF  │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘

CF (Carry Flag)      - Set if arithmetic operation generates carry/borrow
PF (Parity Flag)     - Set if result has even number of 1 bits
AF (Auxiliary Flag)  - Used for BCD arithmetic
ZF (Zero Flag)       - Set if result is zero
SF (Sign Flag)       - Set if result is negative (MSB = 1)
TF (Trap Flag)       - Used for single-step debugging
IF (Interrupt Flag)  - Enable/disable interrupts
DF (Direction Flag)  - String operation direction (0=increment, 1=decrement)
OF (Overflow Flag)   - Set if signed arithmetic overflow occurs
```

### Segment Registers

```
┌──────────────────────────────────────────────────────────────┐
│ CS - Code Segment                                            │
│ DS - Data Segment                                            │
│ SS - Stack Segment                                           │
│ ES - Extra Segment                                           │
│ FS - General Purpose (often thread-local storage)            │
│ GS - General Purpose (often kernel data structures)          │
└──────────────────────────────────────────────────────────────┘

Note: In 64-bit mode, segmentation is largely disabled.
FS and GS are still used for special purposes.
```

### SIMD Registers

```
SSE Registers (128-bit):
┌────────────────────────────────────┐
│ XMM0 - XMM15                       │  128 bits each
│ Used for: float/double operations  │
└────────────────────────────────────┘

AVX Registers (256-bit):
┌────────────────────────────────────┐
│ YMM0 - YMM15                       │  256 bits each
│ Lower 128 bits overlap with XMM    │
└────────────────────────────────────┘

AVX-512 Registers (512-bit):
┌────────────────────────────────────┐
│ ZMM0 - ZMM31                       │  512 bits each
│ Lower 256 bits overlap with YMM    │
└────────────────────────────────────┘
```

---

## Memory Architecture

### Virtual Address Space Layout (Linux x86_64)

```
┌──────────────────────────────────────────┐ 0xFFFFFFFFFFFFFFFF
│        Kernel Space (Upper 128TB)        │
│  ┌────────────────────────────────────┐  │
│  │   Kernel Code and Data             │  │
│  └────────────────────────────────────┘  │
├──────────────────────────────────────────┤ 0xFFFF800000000000
│      Non-canonical Address Space         │
│        (48-bit address space)            │
├──────────────────────────────────────────┤ 0x00007FFFFFFFFFFF
│        User Space (Lower 128TB)          │
│  ┌────────────────────────────────────┐  │
│  │   Stack (grows downward)           │  │ ~0x00007FFFFFFFFFFF
│  │            ↓                       │  │
│  │                                    │  │
│  │   Memory Mapped Region             │  │
│  │   (shared libraries, mmap)         │  │
│  │                                    │  │
│  │            ↑                       │  │
│  │   Heap (grows upward)              │  │
│  ├────────────────────────────────────┤  │
│  │   BSS Segment (uninitialized)      │  │
│  ├────────────────────────────────────┤  │
│  │   Data Segment (initialized)       │  │
│  ├────────────────────────────────────┤  │
│  │   Text Segment (code)              │  │ ~0x400000
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘ 0x0000000000000000
```

### Memory Addressing Modes

x86_64 supports various addressing modes:

```
1. Immediate:        mov rax, 42          ; Direct value
2. Register:         mov rax, rbx         ; Register to register
3. Direct:           mov rax, [0x1000]    ; Absolute address
4. Register Indirect: mov rax, [rbx]       ; Address in register
5. Base + Offset:    mov rax, [rbx + 8]   ; Base + displacement
6. Indexed:          mov rax, [rbx + rcx] ; Base + index
7. Scaled Indexed:   mov rax, [rbx + rcx*4] ; Base + index*scale
8. Full SIB:         mov rax, [rbx + rcx*4 + 8] ; All combined

SIB (Scale-Index-Base) Format:
┌───────────────────────────────────────────────────────────┐
│ [base + index*scale + displacement]                       │
│                                                           │
│ base:         Any GPR (RBX, RBP, R8-R15, etc.)            │
│ index:        Any GPR except RSP                          │
│ scale:        1, 2, 4, or 8                               │
│ displacement: 8-bit or 32-bit signed offset               │
└───────────────────────────────────────────────────────────┘
```

### Cache Hierarchy

```
┌────────────────────────────────────────────────────────────┐
│                      CPU Core                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  L1 Data Cache (32KB)      L1 Instruction Cache      │  │
│  │  Access: 4-5 cycles        (32KB) Access: 4-5 cycles │  │
│  └────────────────┬───────────────────────┬─────────────┘  │
│                   │                       │                │
│  ┌────────────────┴───────────────────────┴──────────────┐ │
│  │           L2 Unified Cache (256KB-1MB)                │ │
│  │              Access: ~12 cycles                       │ │
│  └────────────────────────┬──────────────────────────────┘ │
└───────────────────────────┼────────────────────────────────┘
                            │
         ┌──────────────────┴──────────────────┐
         │   L3 Shared Cache (8MB-64MB)        │
         │      Access: ~40-75 cycles          │
         └──────────────────┬──────────────────┘
                            │
         ┌──────────────────┴──────────────────┐
         │        Main Memory (RAM)            │
         │      Access: ~200-300 cycles        │
         └─────────────────────────────────────┘

Cache Line Size: 64 bytes (typical)
```

---

## Instruction Set Architecture

### Instruction Format

x86_64 uses variable-length instruction encoding (1 to 15 bytes):

```
┌──────┬──────┬──────┬──────┬─────┬──────┬──────────────┐
│Prefix│ REX  │OpCode│ModR/M│ SIB │Displ.│  Immediate   │
│(opt) │(opt) │(1-3) │(opt) │(opt)│(opt) │   (opt)      │
└──────┴──────┴──────┴──────┴─────┴──────┴──────────────┘
1 byte  1 byte 1-3 b   1 byte 1 byte 1,2,4  1,2,4,8 bytes

REX Prefix (for 64-bit operations):
┌───┬───┬───┬───┬───┬───┬───┬───┐
│ 7 │ 6 │ 5 │ 4 │ 3 │ 2 │ 1 │ 0 │
├───┼───┼───┼───┼───┼───┼───┼───┤
│ 0 │ 1 │ 0 │ 0 │ W │ R │ X │ B │
└───┴───┴───┴───┴───┴───┴───┴───┘
                  │   │   │   │
                  │   │   │   └─ Extension of ModR/M r/m field, SIB base
                  │   │   └───── Extension of SIB index field
                  │   └───────── Extension of ModR/M reg field
                  └───────────── 0 = operand size default, 1 = 64-bit

ModR/M Byte:
┌────────┬────────┬────────┐
│ Mod    │  Reg   │  R/M   │
│ (2bit) │ (3bit) │ (3bit) │
└────────┴────────┴────────┘
   │        │        │
   │        │        └─ Register/Memory operand
   │        └────────── Register operand
   └─────────────────── Addressing mode
```

### Instruction Categories

```
┌─────────────────────────────────────────────────────────────┐
│ Data Movement                                               │
├─────────────────────────────────────────────────────────────┤
│ mov, movsx, movzx, lea, push, pop, xchg, cmov               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Arithmetic                                                  │
├─────────────────────────────────────────────────────────────┤
│ add, sub, mul, imul, div, idiv, inc, dec, neg, adc, sbb     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Logical                                                     │
├─────────────────────────────────────────────────────────────┤
│ and, or, xor, not, test, shl, shr, sal, sar, rol, ror       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Control Flow                                                │
├─────────────────────────────────────────────────────────────┤
│ jmp, je/jz, jne/jnz, jg, jl, jge, jle, call, ret, loop      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ String Operations                                           │
├─────────────────────────────────────────────────────────────┤
│ movs, cmps, scas, lods, stos, rep prefix                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ SIMD (SSE/AVX)                                              │
├─────────────────────────────────────────────────────────────┤
│ movaps, addps, mulps, etc. (packed operations)              │
└─────────────────────────────────────────────────────────────┘
```

---

## Calling Conventions

### System V AMD64 ABI (Linux, macOS, BSD)

```
Function Arguments:
┌─────────────────────────────────────────────────────────────┐
│ Integer/Pointer Arguments:                                  │
│   1st: RDI                                                  │
│   2nd: RSI                                                  │
│   3rd: RDX                                                  │
│   4th: RCX                                                  │
│   5th: R8                                                   │
│   6th: R9                                                   │
│   7th+: Stack (right-to-left)                               │
│                                                             │
│ Floating-Point Arguments:                                   │
│   1st-8th: XMM0-XMM7                                        │
│   9th+: Stack                                               │
│                                                             │
│ Return Values:                                              │
│   Integer/Pointer: RAX (RDX for 128-bit)                    │
│   Floating-Point: XMM0 (XMM1 for complex)                   │
└─────────────────────────────────────────────────────────────┘

Register Preservation:
┌─────────────────────────────────────────────────────────────┐
│ Caller-Saved (Volatile):                                    │
│   RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM15               │
│   (Can be modified by callee)                               │
│                                                             │
│ Callee-Saved (Non-Volatile):                                │
│   RBX, RBP, R12-R15                                         │
│   (Must be preserved by callee)                             │
│                                                             │
│ Special:                                                    │
│   RSP - Stack pointer (must be preserved)                   │
│   RBP - Frame pointer (usually preserved)                   │
└─────────────────────────────────────────────────────────────┘
```

### Stack Frame Layout

```
                    High Memory
        ┌──────────────────────────────┐
        │    Previous Stack Frame      │
        ├──────────────────────────────┤
        │  Argument 7 (if needed)      │
        ├──────────────────────────────┤
        │  Return Address              │  ← Pushed by CALL
        ├──────────────────────────────┤
        │  Saved RBP                   │  ← RBP pushed, new RBP = RSP
        ├──────────────────────────────┤ ← RBP (frame pointer)
        │  Local Variables             │
        ├──────────────────────────────┤
        │  Saved Registers             │  (RBX, R12-R15 if used)
        ├──────────────────────────────┤
        │  Temporary Storage           │
        ├──────────────────────────────┤
        │  Arguments for next call     │
        ├──────────────────────────────┤ ← RSP (stack pointer)
        │         ↓ (growth)           │
                    Low Memory

Function Prologue:
    push rbp              ; Save old frame pointer
    mov rbp, rsp          ; Set new frame pointer
    sub rsp, N            ; Allocate space for locals

Function Epilogue:
    mov rsp, rbp          ; Deallocate locals
    pop rbp               ; Restore old frame pointer
    ret                   ; Return to caller
```

### Microsoft x64 Calling Convention (Windows)

```
Function Arguments:
┌─────────────────────────────────────────────────────────────┐
│ Integer/Pointer Arguments:                                  │
│   1st: RCX                                                  │
│   2nd: RDX                                                  │
│   3rd: R8                                                   │
│   4th: R9                                                   │
│   5th+: Stack (right-to-left)                               │
│                                                             │
│ Floating-Point Arguments:                                   │
│   1st-4th: XMM0-XMM3 (corresponding to position)            │
│   5th+: Stack                                               │
│                                                             │
│ Shadow Space:                                               │
│   Caller must allocate 32 bytes on stack (4 register args)  │
└─────────────────────────────────────────────────────────────┘

Stack Alignment:
- Must be 16-byte aligned before CALL
- After CALL (return address pushed), RSP is misaligned by 8
- Function prologue typically: sub rsp, 40 (32 shadow + 8 align)
```

---

## System Architecture

### Protection Rings

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   Ring 0 (Kernel Mode)                                      │
│   ┌─────────────────────────────────────────────────────┐   │
│   │ - Full hardware access                              │   │
│   │ - Can execute privileged instructions               │   │
│   │ - Direct I/O access                                 │   │
│   │ - Memory management                                 │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   Ring 1, 2 (Rarely used)                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │ - Device drivers (historical)                       │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   Ring 3 (User Mode)                                        │
│   ┌─────────────────────────────────────────────────────┐   │
│   │ - Limited hardware access                           │   │
│   │ - Must use system calls for privileged operations   │   │
│   │ - Protected memory space                            │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### System Calls

```
Linux System Call Mechanism (x86_64):
┌─────────────────────────────────────────────────────────────┐
│ Modern Method: syscall instruction                          │
│                                                             │
│ Setup:                                                      │
│   RAX = syscall number                                      │
│   RDI = 1st argument                                        │
│   RSI = 2nd argument                                        │
│   RDX = 3rd argument                                        │
│   R10 = 4th argument (not RCX!)                             │
│   R8  = 5th argument                                        │
│   R9  = 6th argument                                        │
│                                                             │
│ Execute:                                                    │
│   syscall                                                   │
│                                                             │
│ Result:                                                     │
│   RAX = return value (or -errno on error)                   │
└─────────────────────────────────────────────────────────────┘

Common System Calls:
┌──────┬─────────────────────────────────────────────────────┐
│  0   │ read(fd, buf, count)                                │
│  1   │ write(fd, buf, count)                               │
│  2   │ open(filename, flags, mode)                         │
│  3   │ close(fd)                                           │
│  9   │ mmap(addr, length, prot, flags, fd, offset)         │
│  60  │ exit(status)                                        │
└──────┴─────────────────────────────────────────────────────┘
```

### Page Table Structure

```
48-bit Virtual Address Layout:
┌────┬────┬────┬────┬────────────┐
│ 47 │ 39 │ 30 │ 21 │ 12       0 │
├────┼────┼────┼────┼────────────┤
│PML4│PDPT│ PD │ PT │   Offset   │
└────┴────┴────┴────┴────────────┘
 9bit  9bit 9bit 9bit   12 bits

4-Level Page Table:
┌────────────────────────────────────┐
│ CR3 Register (Page Table Base)    │
└─────────────────┬──────────────────┘
                  ↓
         ┌────────────────┐
         │ PML4 (Level 4) │  512 entries
         └────────┬───────┘
                  ↓
         ┌────────────────┐
         │ PDPT (Level 3) │  512 entries
         └────────┬───────┘
                  ↓
         ┌────────────────┐
         │  PD (Level 2)  │  512 entries
         └────────┬───────┘
                  ↓
         ┌────────────────┐
         │  PT (Level 1)  │  512 entries
         └────────┬───────┘
                  ↓
         ┌────────────────┐
         │  Physical Page │  4KB
         └────────────────┘

Page Table Entry Format:
┌───┬───┬───┬───┬───┬───────────────────┬───┬───┬───┐
│63 │62 │...│12 │...│ Physical Address  │...│ 1 │ 0 │
├───┼───┼───┼───┼───┼───────────────────┼───┼───┼───┤
│NX │...│...│...│...│   [51:12]         │...│R/W│ P │
└───┴───┴───┴───┴───┴───────────────────┴───┴───┴───┘
 │                                              │   │
 │                                              │   └─ Present
 │                                              └───── Read/Write
 └──────────────────────────────────────────────────── No Execute
```

---

## Performance Considerations

### Pipeline Architecture

```
Modern x86_64 processors use deep pipelines:

┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│ Fetch   │ Decode  │ Execute │ Memory  │Writeback│ Retire  │
│ (IF)    │ (ID)    │ (EX)    │ (MEM)   │ (WB)    │         │
└─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘

Superscalar Execution (multiple instructions per cycle):
┌───────────────────────────────────────────────────────────┐
│  Inst 1  →  [Decode]  →  [Port 0]  →  [ALU]  →  Result    │
│  Inst 2  →  [Decode]  →  [Port 1]  →  [ALU]  →  Result    │
│  Inst 3  →  [Decode]  →  [Port 2]  →  [Load] →  Result    │
│  Inst 4  →  [Decode]  →  [Port 3]  →  [Store]→  Result    │
└───────────────────────────────────────────────────────────┘

Execution Ports (Intel Skylake example):
Port 0: ALU, Vector, Branch
Port 1: ALU, Vector
Port 2: Load (AGU)
Port 3: Load (AGU)
Port 4: Store (Data)
Port 5: ALU, Vector
Port 6: Branch, ALU
Port 7: Store (AGU)
```

### Branch Prediction

```
┌──────────────────────────────────────────────────────────────┐
│ Branch Predictor Accuracy: ~95-99%                           │
│                                                              │
│ Misprediction Penalty: 15-20 cycles                          │
│                                                              │
│ Types:                                                       │
│  - Static: Predict taken for backward branches               │
│  - Dynamic: Learn from history                               │
│  - Two-level adaptive predictor                              │
│  - Tournament predictor (multiple algorithms)                │
└──────────────────────────────────────────────────────────────┘

Optimization Tips:
1. Make branches predictable
2. Use conditional moves (CMOV) for simple conditions
3. Avoid branching in hot loops
4. Place likely path first
```

### Memory Alignment

```
Data Alignment Requirements:
┌──────────────┬───────────┬──────────────────────────────────┐
│ Data Type    │ Size      │ Alignment                        │
├──────────────┼───────────┼──────────────────────────────────┤
│ byte         │ 1 byte    │ 1 byte (no requirement)          │
│ word         │ 2 bytes   │ 2 bytes                          │
│ dword        │ 4 bytes   │ 4 bytes                          │
│ qword        │ 8 bytes   │ 8 bytes                          │
│ xmmword      │ 16 bytes  │ 16 bytes (required for some ops) │
│ ymmword      │ 32 bytes  │ 32 bytes (required for some ops) │
│ zmmword      │ 64 bytes  │ 64 bytes (required for some ops) │
└──────────────┴───────────┴──────────────────────────────────┘

Misaligned Access:
- Can cause significant performance degradation
- May require multiple memory operations
- Some instructions require alignment (e.g., older SSE)
```

### Instruction Latency and Throughput

```
Common Instruction Performance (approximate):
┌──────────────────┬──────────┬────────────┬────────────────┐
│ Instruction      │ Latency  │ Throughput │ Execution Port │
├──────────────────┼──────────┼────────────┼────────────────┤
│ mov reg, reg     │ 1 cycle  │ 4/cycle    │ Any            │
│ add/sub          │ 1 cycle  │ 4/cycle    │ 0,1,5,6        │
│ imul (64-bit)    │ 3 cycles │ 1/cycle    │ 1              │
│ div (64-bit)     │ 25-90    │ ~25 cycles │ 0              │
│ load (L1 hit)    │ 4 cycles │ 2/cycle    │ 2,3            │
│ store            │ 1 cycle  │ 1/cycle    │ 4,7            │
│ jump (predicted) │ 1-2      │ 2/cycle    │ 6              │
└──────────────────┴──────────┴────────────┴────────────────┘
```

### Optimization Strategies

```
┌──────────────────────────────────────────────────────────────┐
│ 1. Register Allocation                                       │
│    - Keep frequently used data in registers                  │
│    - Use all 16 general-purpose registers                    │
│                                                              │
│ 2. Loop Optimization                                         │
│    - Unroll loops to reduce branch overhead                  │
│    - Use SIMD for data-parallel operations                   │
│                                                              │
│ 3. Cache Optimization                                        │
│    - Keep working set in L1/L2 cache                         │
│    - Use prefetch instructions for predictable access        │
│    - Align hot data to cache line boundaries (64 bytes)      │
│                                                              │
│ 4. Branch Optimization                                       │
│    - Reduce unpredictable branches                           │
│    - Use conditional moves where appropriate                 │
│                                                              │
│ 5. Instruction Selection                                     │
│    - Avoid expensive operations (div, sqrt)                  │
│    - Use lea for address calculation and arithmetic          │
│    - Prefer shifts over multiplication by powers of 2        │
└──────────────────────────────────────────────────────────────┘
```

### Instruction Lifecycle: Fetch → Decode → Execute

```
┌────────────────────────────────────────────────────────────────────────────┐
│ 1. Instruction Fetch (IF)                                                  │
│    - RIP points at next instruction                                        │
│    - L1 I-cache supplies 16 bytes per cycle                                │
│    - Branch predictor speculatively chooses next RIP                       │
│                                                                            │
│ 2. Decode (ID)                                                             │
│    - Complex CISC instructions translated into simpler µops                │
│    - Up to 4 instructions decoded per cycle (depends on µarch)             │
│                                                                            │
│ 3. Rename / Dispatch                                                       │
│    - Architectural registers (RAX, RBX, …) mapped to physical registers    │
│    - Eliminates false dependencies                                         │
│                                                                            │
│ 4. Execute (EX)                                                            │
│    - µops scheduled onto execution ports (ALUs, AGUs, FP units)            │
│    - Loads/stores issue to memory subsystem                                │
│                                                                            │
│ 5. Memory (MEM)                                                            │
│    - Addresses calculated, cache hierarchy accessed                        │
│    - Store buffer holds pending writes                                     │
│                                                                            │
│ 6. Write Back & Retire (WB)                                                │
│    - Results written to physical regs                                      │
│    - In-order retirement commits architectural state                       │
│                                                                            │
│ 7. Repeat                                                                  │
│    - Branch misprediction triggers pipeline flush and restart              │
└────────────────────────────────────────────────────────────────────────────┘

Pipeline depth varies (Skylake ≈14 stages). Out-of-order cores keep hundreds
of µops in flight, but architectural state appears in-order thanks to the
retirement stage. Front-end stalls (I-cache misses, decode bottlenecks) or
back-end stalls (memory latency, execution port pressure) limit throughput.
```

### Program Loading and Memory Mapping (Linux x86_64)

```
1. User launches program (execve)
   - Shell issues execve syscall
   - Kernel loads ELF headers from disk (page cache)

2. ELF Loader in Kernel
   - Validates ELF64 header, entry point, program headers
   - Creates new virtual address space (mm_struct)
   - Initializes stack, argument vector, environment block

3. Memory Mapping (simplified)
┌──────────────────────────────────────────────────────────────┐
│ 0x00007FFFFFFFF000  ← Stack top (grows downward)             │
│            ...                                               │
│ Guard page                                                   │
│ ├──────────────────────────────────────────────────────────┤ │
│ │  Stack (arguments, locals)                               │ │
│ └──────────────────────────────────────────────────────────┘ │
│ 0x00007FFF...                                                │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │  mmap region (shared libs, JIT code, files)              │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │  Heap (brk) – grows upward                               │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │  .bss  (zero-initialized data)                           │ │
│ ├──────────────────────────────────────────────────────────┤ │
│ │  .data (initialized globals)                             │ │
│ ├──────────────────────────────────────────────────────────┤ │
│ │  .text (code)                                            │ │
│ └──────────────────────────────────────────────────────────┘ │
│ 0x0000000000400000  ← Typical load address for PIE binaries  │
└──────────────────────────────────────────────────────────────┘

4. Page Tables
   - Each virtual page (commonly 4 KiB) mapped to physical frames
   - Permissions set per page (RX for .text, RW for .data, etc.)
   - Copy-on-write pages used for sharing code segments and delaying heap/stack
     allocation until first write.

5. Transfer to User Space
   - Kernel sets RIP to entry point (e.g., `_start`)
   - Sets RSP to top of user stack containing argc/argv/envp
   - Executes `sysret`/`iret` returning to user mode

6. Dynamic Linker (ld-linux)
   - Runs before main program
   - Resolves shared library symbols, applies relocations
   - Calls program’s entry point (`_start` → `__libc_start_main` → `main`)

During execution the MMU enforces isolation: attempts to execute from RW pages
trigger NX faults; user pages cannot access kernel addresses due to page table
permissions (and, on modern kernels, the kernel address space is unmapped while
running user code via KPTI).
```

---

## Assembler Syntax

### Intel vs AT&T Syntax

```
┌──────────────────────────────────────────────────────────────┐
│                    Intel Syntax (NASM, MASM)                 │
├──────────────────────────────────────────────────────────────┤
│ mov rax, rbx              ; Destination first                │
│ mov rax, [rbx + 8]        ; No size prefix on registers      │
│ mov QWORD [rbx], 42       ; Size specified on memory         │
│ add rax, 10               ; Decimal by default               │
│ mov rax, 0x10             ; Hex with 0x prefix               │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                    AT&T Syntax (GAS)                         │
├──────────────────────────────────────────────────────────────┤
│ movq %rbx, %rax           ; Source first, % prefix           │
│ movq 8(%rbx), %rax        ; Different address syntax         │
│ movq $42, (%rbx)          ; $ for immediates                 │
│ addq $10, %rax            ; Size suffix (q = quad)           │
│ movq $0x10, %rax          ; Hex with 0x prefix               │
└──────────────────────────────────────────────────────────────┘
```

---

## Conclusion

x86_64 is a complex, powerful architecture with:
- Rich instruction set with extensions (SSE, AVX, etc.)
- Flexible addressing modes
- Backward compatibility
- Advanced features (virtualization, security extensions)

This document provides a foundation. The following example programs will demonstrate these concepts in practice.

