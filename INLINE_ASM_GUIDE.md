# Inline Assembly Guide

Inline assembly embeds CPU instructions directly inside a high-level language such as C or C++. It lets you mix portable logic with hand-crafted machine instructions for situations where you need exact control. This guide summarizes when and how to use inline assembly, with references to the `09_inline_asm_c.c` example under `x86_64/`.

## Why Use Inline Assembly?

| Scenario | Reason |
|----------|--------|
| Special CPU instructions | Some instructions (`rdtsc`, `cpuid`, `lock cmpxchg`, SIMD shuffles, etc.) lack intrinsics or library wrappers. Inline asm lets you emit them exactly when required. |
| Precise ABI/register control | Context switches, custom prologues/epilogues, or system calls need exact register usage that the compiler might alter. Inline asm enforces contracts down to single registers. |
| Hot-path micro-optimization | Cryptography, checksum loops, or DSP kernels sometimes benchmark faster when hand-tuned. Inline asm can surgically replace a short sequence without rewriting the entire function. |
| Hardware / OS interfaces | Interacting with memory-mapped I/O, issuing `syscall`/`svc`, or touching control registers requires explicit instruction ordering the compiler must not rearrange. |
| Lock-free or atomic primitives | Some atomic operations rely on instruction pairs (`ldrex/strex`, `lock xchg`) not available in standard libraries. Inline asm enables custom concurrency constructs. |
| Instrumentation/timing | Reading timers (`rdtsc`) or inserting fences (`mfence`, `dsb`) must happen at precise points. Marking asm as `volatile` with `memory` clobbers prevents unwanted reordering.

## When *Not* to Use It

- **Intrinsics exist:** prefer compiler intrinsics (`__builtin_popcountll`, `_mm_add_ps`) when available—they are portable and allow better optimization.
- **Large assembly blocks:** for complex routines, use separate `.s`/`.asm` files; inline asm should stay small and focused.
- **Portability concerns:** inline asm ties a translation unit to a single architecture/assembler syntax. For multi-target codebases, isolate asm per platform.

## GCC/Clang Extended Inline ASM Cheatsheet

```c
asm volatile (
    "rdtsc\n\t"              // instruction template
    : "=a" (lo), "=d" (hi)     // outputs
    :                          // inputs (none here)
    : "memory"                // clobbers
);
```

- **`asm` vs `asm volatile`:** use `volatile` for instructions with side effects so the compiler can’t remove or reorder them.
- **Outputs (`"=r" (out)`):** `"="` means write-only; `"+"` means read-write; `"&"` means early clobber.
- **Inputs (`"r" (in)`):** informs the compiler it can choose any register/memory matching the constraint (`"r"`, `"m"`, `"a"`, `"d"`, `"x"`, etc.).
- **Clobbers:** list every register or resource the asm modifies but doesn’t list as an output (e.g., `"rcx"`, `"r11"`, `"memory"`).
- **Templates:** use `%%` to emit a literal `%`; references like `%0` refer to operands in order (outputs first, then inputs).

## Patterns from `x86_64/09_inline_asm_c.c`

| Section | Purpose |
|---------|---------|
| Basic arithmetic | Shows register constraints and simple ALU instructions. |
| Memory ops (`rep movsb`, `stosb`) | Demonstrates `"+D"`, `"+S"`, `"+c"` constraints for string instructions. |
| Bit tricks (`bsr`, `bsf`, `popcnt`) | Useful when intrinsics are missing or to ensure exact instruction use. |
| Atomics (`lock inc`, `cmpxchg`) | Build custom spinlocks or lock-free structures. |
| System calls (`syscall`) | Issue Linux syscalls directly by loading registers and executing `syscall`. |
| SIMD (`movups`, `addps`) | Emit specific vector instructions when intrinsics aren’t desired. |
| Timing (`rdtsc`, `cpuid`) | Serialize and read time-stamp counters for benchmarking. |

## Best Practices

1. **Keep snippets small.** Let C/C++ handle control flow; inline asm should handle only the instructions you truly need.
2. **Document every operand.** Explain why a register is used, what constraints mean, and list clobbers meticulously.
3. **Guard platform-specific code.** Use `#ifdef __x86_64__` or similar to prevent compilation on unsupported targets.
4. **Prefer intrinsics when available.** They’re safer and often generate identical machine code.
5. **Test with optimizations enabled.** Inline asm interacts with register allocation differently under `-O2` or `-O3`.
6. **Use `memory` clobber when touching arbitrary memory.** This stops the compiler from reordering loads/stores around your asm block.
7. **Fallback paths.** Provide pure-C alternatives when possible for portability or testing.

## Example: Inline System Call (x86_64 Linux)

```c
ssize_t write_syscall(int fd, const void *buf, size_t len) {
    ssize_t ret;
    asm volatile (
        "mov $1, %%rax\n\t"   // SYS_write
        "syscall\n\t"
        : "=a" (ret)
        : "D" (fd), "S" (buf), "d" (len)
        : "rcx", "r11", "memory"
    );
    return ret;
}
```

- `"D"`, `"S"`, `"d"` ensure parameters land in `RDI`, `RSI`, `RDX` per the Linux syscall ABI.
- `rcx` and `r11` must be clobbered because `syscall` overwrites them.

## Example: Atomic Increment (ARM64)

```c
static inline void atomic_inc(long *ptr) {
    asm volatile (
        "1:\n\t"
        "ldxr %w0, [%1]\n\t"
        "add %w0, %w0, #1\n\t"
        "stxr %w2, %w0, [%1]\n\t"
        "cbnz %w2, 1b\n\t"
        : "=&r" (tmp), "+Q" (*ptr), "=&r" (status)
        :
        : "memory"
    );
}
```

- Uses ARM’s exclusive load/store pair to implement a lock-free increment.
- `cbnz` loops if the store fails due to contention.

## Summary

Inline assembly is a powerful tool for injecting precise machine instructions into high-level code. Use it when you need:
- Exact instruction sequences.
- Specific register layouts or calling conventions.
- Hand-tuned performance for critical hotspots.
- Direct access to hardware features.

Always balance power against portability and maintainability. Keep inline asm small, well-documented, and guarded so the rest of your code stays readable and portable.
