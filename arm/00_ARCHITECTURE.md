# ARM Architecture Overview

## Table of Contents
1. [Introduction](#introduction)
2. [ARM Variants](#arm-variants)
3. [Register Architecture](#register-architecture)
4. [Instruction Set](#instruction-set)
5. [Memory Architecture](#memory-architecture)
6. [Calling Conventions](#calling-conventions)
7. [System Architecture](#system-architecture)
8. [Performance Considerations](#performance-considerations)

---

## Introduction

ARM (Advanced RISC Machine, originally Acorn RISC Machine) is a family of RISC (Reduced Instruction Set Computer) architectures used extensively in:

- **Mobile devices** (smartphones, tablets)
- **Embedded systems** (IoT, automotive)
- **Single-board computers** (Raspberry Pi)
- **Servers** (AWS Graviton, Apple M1/M2/M3)

Key ARM Characteristics:
- **RISC philosophy** - Simple, regular instructions
- **Load-store architecture** - Only load/store access memory
- **Fixed-length instructions** - 32-bit (ARM) or 16/32-bit (Thumb)
- **Conditional execution** - Most instructions can be conditionally executed
- **Large register file** - 16 general-purpose registers (ARM32), 31 (ARM64)
- **Energy efficient** - Low power consumption

---

## ARM Variants

### ARM32 (AArch32, ARMv7)

```
ARM State:     32-bit instructions, full feature set
Thumb State:   16-bit instructions, compact code
Thumb-2:       Mix of 16-bit and 32-bit instructions
```

### ARM64 (AArch64, ARMv8+)

```
64-bit architecture, new instruction set
Not compatible with ARM32 at instruction level
Removes conditional execution (except branches)
64-bit registers (X0-X30), 32-bit (W0-W30)
```

### Comparison

```
┌─────────────────┬────────────────┬────────────────┐
│ Feature         │ ARM32          │ ARM64          │
├─────────────────┼────────────────┼────────────────┤
│ Registers       │ 16 (32-bit)    │ 31 (64-bit)    │
│ PC visible      │ Yes (R15)      │ No             │
│ Cond. execution │ Most instrs    │ Branches only  │
│ Instruction size│ 32-bit/16-bit  │ 32-bit         │
│ Barrel shifter  │ Yes            │ Limited        │
│ SIMD            │ NEON (opt)     │ NEON (standard)│
└─────────────────┴────────────────┴────────────────┘
```

---

## Register Architecture

### ARM32 Register Set

```
General Purpose Registers (R0-R15):
┌────────────────────────────────────────────────────┐
│ R0-R12   │ General purpose (R0-R3 for args)        │
│ R13 (SP) │ Stack Pointer                           │
│ R14 (LR) │ Link Register (return address)          │
│ R15 (PC) │ Program Counter                         │
└────────────────────────────────────────────────────┘

Register Layout (32-bit):
┌───────────────────────────────────────────────────┐
│ 31                                              0 │
│ ├───────────────────────────────────────────────┤ │
│                    32 bits                        │
└───────────────────────────────────────────────────┘

CPSR - Current Program Status Register:
┌───┬───┬───┬───┬───┬───────────┬───────────────┐
│ 31│ 30│ 29│ 28│ 27│ ...       │ 4 3 2 1 0     │
├───┼───┼───┼───┼───┼───────────┼───────────────┤
│ N │ Z │ C │ V │ Q │ IT/GE bits│ Mode bits     │
└───┴───┴───┴───┴───┴───────────┴───────────────┘
  │   │   │   │
  │   │   │   └─ Overflow flag
  │   │   └───── Carry flag
  │   └───────── Zero flag
  └───────────── Negative flag
```

### ARM64 Register Set

```
General Purpose Registers:
┌────────────────────────────────────────────────────┐
│ X0-X7    │ Argument/result registers               │
│ X8       │ Indirect result location                │
│ X9-X15   │ Temporary registers                     │
│ X16-X17  │ IP0, IP1 (intra-procedure-call)         │
│ X18      │ Platform register                       │
│ X19-X28  │ Callee-saved registers                  │
│ X29 (FP) │ Frame Pointer                           │
│ X30 (LR) │ Link Register                           │
│ SP       │ Stack Pointer (not X31)                 │
│ XZR/WZR  │ Zero register (reads as 0)              │
└────────────────────────────────────────────────────┘

Register Access (ARM64):
┌───────────────────────────────────────────────────┐
│ 64-bit    32-bit      Access                      │
├───────────────────────────────────────────────────┤
│ X0        W0          Lower 32 bits of X0         │
│ X1        W1          Lower 32 bits of X1         │
│ ...       ...         ...                         │
│ X30       W30         Lower 32 bits of X30        │
└───────────────────────────────────────────────────┘

64-bit Register Layout:
┌───────────────────────────────────────────────────┐
│ 63                              32│31           0 │
│ ├───────────────────────────────┼───────────────┤ │
│              X register (64-bit)                  │
│                                   │ W register    │
└───────────────────────────────────────────────────┘

PSTATE - Processor State (ARM64):
┌───┬───┬───┬───┬───────────────────┐
│ N │ Z │ C │ V │ Other flags       │
└───┴───┴───┴───┴───────────────────┘
  │   │   │   │
  │   │   │   └─ Overflow
  │   │   └───── Carry
  │   └───────── Zero
  └───────────── Negative
```

### NEON/SIMD Registers

```
ARM32 NEON:
┌────────────────────────────────────────────────────┐
│ Q0-Q15   │ 128-bit SIMD registers                  │
│ D0-D31   │ 64-bit SIMD registers (D0=Q0[low])      │
│ S0-S31   │ 32-bit floating-point registers         │
└────────────────────────────────────────────────────┘

ARM64 NEON:
┌────────────────────────────────────────────────────┐
│ V0-V31   │ 128-bit SIMD/FP registers               │
│ Q0-Q31   │ 128-bit view                            │
│ D0-D31   │ 64-bit view (lower half)                │
│ S0-S31   │ 32-bit view (lower quarter)             │
│ H0-H31   │ 16-bit view (lower eighth)              │
│ B0-B31   │ 8-bit view (lowest byte)                │
└────────────────────────────────────────────────────┘

Register Layout:
┌──────────────────────────────────────────────────┐
│ 127                                            0 │
│ ├────────────────────────────────────────────────┤
│                    V0 (128-bit)                  │
│                    Q0 (128-bit)                  │
│                                  │ D0 (64-bit)   │
│                                  │      │ S0 (32)│
└──────────────────────────────────────────────────┘
```

---

## Instruction Set

### ARM32 Instruction Format

```
ARM Instructions (32-bit):
┌─────┬──────┬───────────────────────────────┐
│31 28│27  25│24                           0 │
├─────┼──────┼───────────────────────────────┤
│Cond │ Type │     Instruction Specific      │
└─────┴──────┴───────────────────────────────┘

Condition Codes (bits 31-28):
  0000 = EQ (Equal)
  0001 = NE (Not Equal)
  0010 = CS/HS (Carry Set / Unsigned Higher or Same)
  0011 = CC/LO (Carry Clear / Unsigned Lower)
  0100 = MI (Minus / Negative)
  0101 = PL (Plus / Positive or Zero)
  0110 = VS (Overflow Set)
  0111 = VC (Overflow Clear)
  1000 = HI (Unsigned Higher)
  1001 = LS (Unsigned Lower or Same)
  1010 = GE (Signed Greater or Equal)
  1011 = LT (Signed Less Than)
  1100 = GT (Signed Greater Than)
  1101 = LE (Signed Less or Equal)
  1110 = AL (Always - default)
  1111 = Special
```

### ARM64 Instruction Format

```
ARM64 Instructions (32-bit fixed):
┌──────────────────────────────────────────┐
│ 31                                     0 │
├──────────────────────────────────────────┤
│     Instruction Encoding (32 bits)       │
└──────────────────────────────────────────┘

No condition field in most instructions
Simpler, more regular encoding
```

### Instruction Categories

```
┌─────────────────────────────────────────────────────────────┐
│ Data Processing                                             │
├─────────────────────────────────────────────────────────────┤
│ ARM32: ADD, SUB, MUL, AND, ORR, EOR, MOV, CMP               │
│ ARM64: ADD, SUB, MUL, AND, ORR, EOR, MOV, CMP               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Load/Store                                                  │
├─────────────────────────────────────────────────────────────┤
│ ARM32: LDR, STR, LDM, STM, PUSH, POP                        │
│ ARM64: LDR, STR, LDP, STP                                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Branch                                                      │
├─────────────────────────────────────────────────────────────┤
│ ARM32: B, BL, BX, BLX (with conditions)                     │
│ ARM64: B, BR, BL, BLR, RET, CBZ, CBNZ, TBZ, TBNZ            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ SIMD/NEON                                                   │
├─────────────────────────────────────────────────────────────┤
│ Vector operations on multiple data elements                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Memory Architecture

### Memory Addressing (ARM32)

```
Addressing Modes:

1. Immediate Offset:
   LDR R0, [R1, #4]         ; R0 = memory[R1 + 4]

2. Register Offset:
   LDR R0, [R1, R2]         ; R0 = memory[R1 + R2]

3. Scaled Register:
   LDR R0, [R1, R2, LSL #2] ; R0 = memory[R1 + (R2 << 2)]

4. Pre-indexed:
   LDR R0, [R1, #4]!        ; R1 = R1 + 4, R0 = memory[R1]

5. Post-indexed:
   LDR R0, [R1], #4         ; R0 = memory[R1], R1 = R1 + 4

Load/Store Multiple:
   LDMIA R0, {R1-R5}        ; Load R1-R5 from memory[R0...]
   STMDB R13!, {R0-R12,LR}  ; Push registers to stack
```

### Memory Addressing (ARM64)

```
Addressing Modes:

1. Base register only:
   LDR X0, [X1]             ; X0 = memory[X1]

2. Base + offset:
   LDR X0, [X1, #8]         ; X0 = memory[X1 + 8]

3. Base + register:
   LDR X0, [X1, X2]         ; X0 = memory[X1 + X2]

4. Base + extended register:
   LDR X0, [X1, W2, UXTW #3] ; X0 = mem[X1 + (W2 zero-extended << 3)]

5. Pre-indexed:
   LDR X0, [X1, #8]!        ; X1 = X1 + 8, X0 = memory[X1]

6. Post-indexed:
   LDR X0, [X1], #8         ; X0 = memory[X1], X1 = X1 + 8

Load/Store Pair:
   LDP X0, X1, [SP, #16]    ; Load pair
   STP X0, X1, [SP, #-16]!  ; Store pair with pre-index
```

### Virtual Memory (ARM64)

```
┌──────────────────────────────────────────┐ 0xFFFFFFFFFFFFFFFF
│        Kernel Space                      │
│  ┌────────────────────────────────────┐  │
│  │   Kernel Code and Data             │  │
│  └────────────────────────────────────┘  │
├──────────────────────────────────────────┤ 0xFFFF000000000000
│      Non-canonical addresses             │
├──────────────────────────────────────────┤ 0x0000FFFFFFFFFFFF
│        User Space                        │
│  ┌────────────────────────────────────┐  │
│  │   Stack                            │  │
│  │   ↓                                │  │
│  │                                    │  │
│  │   Memory Mapped                    │  │
│  │                                    │  │
│  │   ↑                                │  │
│  │   Heap                             │  │
│  ├────────────────────────────────────┤  │
│  │   BSS                              │  │
│  ├────────────────────────────────────┤  │
│  │   Data                             │  │
│  ├────────────────────────────────────┤  │
│  │   Text                             │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘ 0x0000000000000000

48-bit virtual addresses (typical)
4KB, 16KB, or 64KB page sizes
```

### Cache Architecture

```
┌────────────────────────────────────────────────────────────┐
│                      CPU Core                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  L1 I-Cache (32-64KB)     L1 D-Cache (32-64KB)       │  │
│  │  Access: 3-4 cycles       Access: 3-4 cycles         │  │
│  └────────────────┬────────────────────┬────────────────┘  │
│                   │                    │                   │
│  ┌────────────────┴────────────────────┴────────────────┐  │
│  │           L2 Unified Cache (256KB-2MB)               │  │
│  │              Access: ~10 cycles                      │  │
│  └────────────────────────┬─────────────────────────────┘  │
└───────────────────────────┼────────────────────────────────┘
                            │
         ┌──────────────────┴──────────────────┐
         │   L3 Cache (2-32MB, optional)       │
         │      Access: ~30-40 cycles          │
         └──────────────────┬──────────────────┘
                            │
         ┌──────────────────┴──────────────────┐
         │        Main Memory (RAM)            │
         │      Access: ~100-200 cycles        │
         └─────────────────────────────────────┘
```

---

## Calling Conventions

### ARM32 AAPCS (ARM Architecture Procedure Call Standard)

```
Function Arguments:
┌─────────────────────────────────────────────────────────────┐
│ Integer/Pointer Arguments:                                  │
│   R0 = 1st argument, also return value                      │
│   R1 = 2nd argument, also return value (64-bit)             │
│   R2 = 3rd argument                                         │
│   R3 = 4th argument                                         │
│   Stack = 5th+ arguments                                    │
│                                                             │
│ Floating-Point Arguments:                                   │
│   S0-S15 / D0-D7 / Q0-Q3 (if VFP/NEON available)            │
└─────────────────────────────────────────────────────────────┘

Register Preservation:
┌─────────────────────────────────────────────────────────────┐
│ Caller-Saved (Volatile):                                    │
│   R0-R3, R12 (IP), R14 (LR)                                 │
│   S0-S15 / D0-D7 / Q0-Q3                                    │
│                                                             │
│ Callee-Saved (Non-Volatile):                                │
│   R4-R11, R13 (SP)                                          │
│   S16-S31 / D8-D15 / Q4-Q7                                  │
└─────────────────────────────────────────────────────────────┘

Stack Alignment:
- 8-byte aligned at function entry (AAPCS)
- Some systems require 16-byte alignment
```

### ARM64 AAPCS64

```
Function Arguments:
┌─────────────────────────────────────────────────────────────┐
│ Integer/Pointer Arguments:                                  │
│   X0 = 1st argument, also return value                      │
│   X1 = 2nd argument                                         │
│   X2 = 3rd argument                                         │
│   X3 = 4th argument                                         │
│   X4 = 5th argument                                         │
│   X5 = 6th argument                                         │
│   X6 = 7th argument                                         │
│   X7 = 8th argument                                         │
│   Stack = 9th+ arguments                                    │
│                                                             │
│ Floating-Point Arguments:                                   │
│   V0-V7 = arguments and return values                       │
└─────────────────────────────────────────────────────────────┘

Register Preservation:
┌─────────────────────────────────────────────────────────────┐
│ Caller-Saved (Volatile):                                    │
│   X0-X18, X30 (LR)                                          │
│   V0-V7, V16-V31                                            │
│                                                             │
│ Callee-Saved (Non-Volatile):                                │
│   X19-X28, X29 (FP), SP                                     │
│   V8-V15 (lower 64 bits only)                               │
└─────────────────────────────────────────────────────────────┘

Stack Alignment:
- 16-byte aligned at function entry (mandatory)
```

### Stack Frame Layout (ARM64)

```
                    High Memory
        ┌──────────────────────────────┐
        │    Previous Stack Frame      │
        ├──────────────────────────────┤
        │  Arguments 9+ (if any)       │
        ├──────────────────────────────┤ ← SP at function entry
        │  Return Address (LR)         │
        ├──────────────────────────────┤
        │  Frame Pointer (old FP)      │
        ├──────────────────────────────┤ ← FP (X29)
        │  Saved Registers (X19-X28)   │
        ├──────────────────────────────┤
        │  Local Variables             │
        ├──────────────────────────────┤
        │  Spill Space                 │
        ├──────────────────────────────┤ ← SP (stack pointer)
        │         ↓ (growth)           │
                    Low Memory

Function Prologue (ARM64):
    stp     x29, x30, [sp, #-16]!   ; Save FP and LR
    mov     x29, sp                  ; Set new frame pointer
    sub     sp, sp, #N               ; Allocate locals

Function Epilogue (ARM64):
    mov     sp, x29                  ; Restore stack pointer
    ldp     x29, x30, [sp], #16      ; Restore FP and LR
    ret                              ; Return
```

---

## System Architecture

### Exception Levels (ARM64)

```
┌─────────────────────────────────────────────────────────────┐
│ EL3 - Secure Monitor (Hypervisor for security states)       │
│   - Highest privilege level                                 │
│   - Manages secure/non-secure state transitions             │
└─────────────────────────────────────────────────────────────┘
            ↑ ↓
┌─────────────────────────────────────────────────────────────┐
│ EL2 - Hypervisor                                            │
│   - Virtualization support                                  │
│   - Manages guest operating systems                         │
└─────────────────────────────────────────────────────────────┘
            ↑ ↓
┌─────────────────────────────────────────────────────────────┐
│ EL1 - Operating System Kernel                               │
│   - Privileged OS code                                      │
│   - Device drivers                                          │
└─────────────────────────────────────────────────────────────┘
            ↑ ↓
┌─────────────────────────────────────────────────────────────┐
│ EL0 - User Applications                                     │
│   - Unprivileged code                                       │
│   - Normal applications                                     │
└─────────────────────────────────────────────────────────────┘
```

### System Calls (Linux ARM64)

```
System Call Mechanism:
┌─────────────────────────────────────────────────────────────┐
│ Setup:                                                      │
│   X8 = syscall number                                       │
│   X0 = 1st argument                                         │
│   X1 = 2nd argument                                         │
│   X2 = 3rd argument                                         │
│   X3 = 4th argument                                         │
│   X4 = 5th argument                                         │
│   X5 = 6th argument                                         │
│                                                             │
│ Execute:                                                    │
│   svc #0         ; Supervisor call                          │
│                                                             │
│ Result:                                                     │
│   X0 = return value                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Performance Considerations

### Pipeline

```
ARM processors use pipelined execution:

Simple Pipeline (ARM Cortex-A7):
┌────────┬────────┬────────┬────────┬─────────┐
│ Fetch  │ Decode │ Execute│ Memory │WriteBack│
└────────┴────────┴────────┴────────┴─────────┘

Advanced Pipeline (ARM Cortex-A72):
- 15-stage pipeline
- Out-of-order execution
- Superscalar (3-way issue)
- Branch prediction
```

### Instruction Characteristics

```
┌────────────────────────────────────────────────────────────┐
│ Most ARM instructions:                                     │
│   - Execute in 1 cycle (pipelined)                         │
│   - Can be predicated (ARM32)                              │
│   - Regular encoding                                       │
│                                                            │
│ Load latency:                                              │
│   - L1 cache hit: 3-4 cycles                               │
│   - L2 cache hit: ~10 cycles                               │
│   - Main memory: ~100-200 cycles                           │
│                                                            │
│ Branch misprediction:                                      │
│   - 10-20 cycle penalty                                    │
└────────────────────────────────────────────────────────────┘
```

### Optimization Tips

```
1. Register Usage
   - Keep data in registers
   - Use callee-saved registers for long-lived data
   - ARM64: 31 registers available

2. Memory Access
   - Keep data aligned (natural alignment)
   - Use load/store pairs (LDP/STP) in ARM64
   - Sequential access for cache efficiency

3. Branches
   - Make branches predictable
   - Use conditional select (CSEL) instead of branches
   - ARM64: Use CBZ/CBNZ for compare-and-branch

4. NEON/SIMD
   - Process multiple elements per instruction
   - Keep vectors aligned (16-byte)
   - Use vector operations for data parallel code

5. ARM64 Advantages
   - More registers (31 vs 16)
   - Simpler instruction set
   - Better integer performance
   - Integrated SIMD (NEON standard)
```

### Instruction Lifecycle: Fetch → Decode → Execute

```
┌────────────────────────────────────────────────────────────────────────────┐
│ 1. Fetch                                                                   │
│    - PC reads next 32-bit (or 16-bit Thumb) instruction from L1 I-cache    │
│    - Branch predictor selects likely next PC                               │
│                                                                            │
│ 2. Decode                                                                  │
│    - Fixed-length encoding allows simple, high-throughput decoders         │
│    - Thumb instructions internally expanded to full 32-bit ops             │
│                                                                            │
│ 3. Rename / Issue (OOO cores)                                              │
│    - Architectural registers (X0–X30) mapped to physical registers         │
│    - Eliminates false dependencies, enables out-of-order scheduling        │
│                                                                            │
│ 4. Execute                                                                 │
│    - ALUs, load/store units, branch units, NEON/FP pipelines process µops  │
│    - big cores (Cortex-A78, X4) can issue 4–6 µops per cycle               │
│                                                                            │
│ 5. Memory Stage                                                            │
│    - Address Generation Units (AGUs) feed the cache hierarchy              │
│    - Store buffers hold pending writes until commit                        │
│                                                                            │
│ 6. Writeback & Commit                                                      │
│    - Results written to physical registers                                 │
│    - Commit stage updates architectural state in order                     │
│                                                                            │
│ 7. Repeat                                                                  │
│    - Pipeline flush on branch mispredict, exception, or interrupt          │
└────────────────────────────────────────────────────────────────────────────┘

big.LITTLE systems pair simple in-order cores (efficient) with deep, out-of-order
cores (performance), but both follow the same fetch→decode→execute lifecycle.
```

### Program Loading and Memory Mapping (Linux/Android on ARM64)

```
1. execve Invocation
   - Kernel validates ELF, allocates new mm_struct, clears old mappings

2. ELF Loader
   - Parses program headers (.text, .data, .bss, PT_LOAD)
   - Maps segments into virtual memory with proper permissions (RX, RW)

3. Virtual Address Layout (simplified)
┌──────────────────────────────────────────────────────────────┐
│ 0x0000FFFFFFFFF000  ← Stack top                              │
│            ↓ Stack grows downward                            │
│ Guard page (unmapped)                                        │
│ ├──────────────────────────────────────────────────────────┤ │
│ │ Stack: argv, envp, call frames                           │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ mmap region: shared libs, JIT, files                     │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ Heap (brk) – grows upward                                │ │
│ └──────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ .bss (zeroed)                                            │ │
│ ├──────────────────────────────────────────────────────────┤ │
│ │ .data (initialized data)                                 │ │
│ ├──────────────────────────────────────────────────────────┤ │
│ │ .text (code, read+execute)                               │ │
│ └──────────────────────────────────────────────────────────┘ │
│ 0x0000000000400000  ← Typical base for PIE binaries          │
└──────────────────────────────────────────────────────────────┘

4. Page Tables & Permissions
   - Each 4/16/64 KiB page mapped with attributes
   - UXN/PXN bits enforce unprivileged/privileged execute-never policies
   - Access permissions (AP) prevent user space from touching kernel pages

5. Dynamic Linker
   - Mapped via PT_INTERP (e.g., `/lib/ld-linux-aarch64.so.1`)
   - Resolves shared libraries, relocations, TLS blocks

6. Transition to User Mode
   - Kernel sets SP, initializes X0=argc, X1=argv, X2=envp
   - Sets PC to entry point (`_start`), returns via `eret` to EL0

7. During Execution
   - MMU + caches enforce isolation
   - On-demand paging loads code/data as accessed
   - Signals/exceptions trap to EL1, kernel handles, returns via `eret`
```

---

## Assembler Syntax

### GNU Assembler (GAS) - ARM Syntax

```assembly
@ Comment (ARM syntax)
// Comment (also valid)

/* Multi-line
   comment */

@ ARM32 examples:
    mov     r0, #42          @ Move immediate
    add     r1, r2, r3       @ r1 = r2 + r3
    ldr     r0, [r1, #4]     @ Load from memory
    str     r0, [r1, #4]!    @ Store with pre-increment

@ ARM64 examples:
    mov     x0, #42          // Move immediate
    add     x1, x2, x3       // x1 = x2 + x3
    ldr     x0, [x1, #8]     // Load from memory
    stp     x0, x1, [sp, #-16]! // Store pair
```

---

## Conclusion

ARM architecture offers:
- **Efficiency** - Low power, high performance
- **Scalability** - From microcontrollers to servers
- **Simplicity** - RISC philosophy, regular instructions
- **Modern features** - SIMD, virtualization, security

ARM64 (AArch64) is the future:
- Clean break from ARM32
- More registers and better encoding
- Better performance
- Industry standard for mobile and embedded

This document provides the foundation. The following examples demonstrate these concepts in practice.

