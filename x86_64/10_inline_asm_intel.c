/*
 * ============================================================================
 * File: 10_inline_asm_intel.c
 * Description: Inline assembly using Intel syntax (destination first)
 * Topics: Intel syntax, .intel_syntax directive, operand order
 * Compiler: GCC with -masm=intel or using .intel_syntax directive
 * Build: gcc -O2 10_inline_asm_intel.c -o 10_inline_asm_intel
 *        OR: gcc -O2 -masm=intel 10_inline_asm_intel.c -o 10_inline_asm_intel
 * ============================================================================
 */

#include <stdio.h>
#include <stdint.h>

/*
 * ============================================================================
 * INTEL SYNTAX BASICS
 * ============================================================================
 * 
 * Intel syntax (NASM, MASM, Intel docs):
 *   - Destination first, source second: mov rax, rbx  (rax = rbx)
 *   - No register prefix: rax, rbx (not %rax, %rbx)
 *   - No immediate prefix: mov rax, 42 (not $42)
 *   - Size on memory operands: QWORD PTR [rbx]
 *   - Memory addressing: [base + index*scale + disp]
 * 
 * AT&T syntax (GAS default):
 *   - Source first, destination second: movq %rbx, %rax
 *   - Register prefix %: %rax, %rbx
 *   - Immediate prefix $: movq $42, %rax
 *   - Size suffix on instruction: movq
 *   - Memory addressing: disp(base, index, scale)
 * 
 * ============================================================================
 */

/*
 * ============================================================================
 * METHOD 1: Using .intel_syntax directive (preferred for clarity)
 * ============================================================================
 */

uint64_t add_intel_explicit(uint64_t a, uint64_t b) {
    uint64_t result;
    
    // Switch to Intel syntax, then back to AT&T
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "mov %0, %1\n\t"              // result = a (dest first!)
        "add %0, %2\n\t"              // result += b
        ".att_syntax prefix\n\t"      // Switch back to AT&T
        : "=r" (result)               // %0 = output
        : "r" (a), "r" (b)            // %1 = a, %2 = b
    );
    
    return result;
}

/*
 * ============================================================================
 * METHOD 2: Using __asm__() with intel_syntax (inline switching)
 * ============================================================================
 */

uint64_t multiply_intel(uint64_t a, uint64_t b) {
    uint64_t result;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "mov rax, %1\n\t"             // Load first operand
        "imul rax, %2\n\t"            // Multiply
        "mov %0, rax\n\t"             // Store result
        ".att_syntax prefix"
        : "=r" (result)
        : "r" (a), "r" (b)
        : "rax"                       // Clobber RAX
    );
    
    return result;
}

/*
 * ============================================================================
 * COMPARISON: Same operation in both syntaxes
 * ============================================================================
 */

// AT&T syntax (default)
uint64_t subtract_att(uint64_t a, uint64_t b) {
    uint64_t result;
    __asm__ (
        "movq %1, %0\n\t"             // Source first: movq src, dest
        "subq %2, %0"                 // Subtract: subq src, dest
        : "=r" (result)
        : "r" (a), "r" (b)
    );
    return result;
}

// Intel syntax (explicit)
uint64_t subtract_intel(uint64_t a, uint64_t b) {
    uint64_t result;
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "mov %0, %1\n\t"              // Dest first: mov dest, src
        "sub %0, %2\n\t"              // Subtract: sub dest, src
        ".att_syntax prefix"
        : "=r" (result)
        : "r" (a), "r" (b)
    );
    return result;
}

/*
 * ============================================================================
 * MEMORY OPERATIONS - Intel Syntax
 * ============================================================================
 */

void copy_memory_intel(void *dest, const void *src, size_t n) {
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "cld\n\t"                     // Clear direction flag
        "rep movsb\n\t"               // Repeat move string byte
        ".att_syntax prefix"
        : "+D" (dest), "+S" (src), "+c" (n)  // RDI, RSI, RCX modified
        :
        : "memory"
    );
}

void fill_memory_intel(void *dest, uint8_t value, size_t n) {
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "cld\n\t"
        "rep stosb\n\t"               // Repeat store string byte
        ".att_syntax prefix"
        : "+D" (dest), "+c" (n)
        : "a" (value)                 // AL register
        : "memory"
    );
}

/*
 * ============================================================================
 * BIT MANIPULATION - Intel Syntax
 * ============================================================================
 */

int count_leading_zeros_intel(uint64_t x) {
    int count;
    
    if (x == 0)
        return 64;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "bsr %0, %1\n\t"              // Bit scan reverse: dest, src
        "xor %0, 63\n\t"              // Convert to leading zeros
        ".att_syntax prefix"
        : "=r" (count)
        : "r" (x)
    );
    
    return count;
}

int popcount_intel(uint64_t x) {
    int count;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "popcnt %0, %1\n\t"           // Population count: dest, src
        ".att_syntax prefix"
        : "=r" (count)
        : "r" (x)
    );
    
    return count;
}

/*
 * ============================================================================
 * ATOMIC OPERATIONS - Intel Syntax
 * ============================================================================
 */

void atomic_increment_intel(int64_t *ptr) {
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "lock inc QWORD PTR [%0]\n\t" // Atomic increment memory
        ".att_syntax prefix"
        : "+r" (ptr)                  // Read-write pointer
        :
        : "memory"
    );
}

int compare_and_swap_intel(uint64_t *ptr, uint64_t old_val, uint64_t new_val) {
    uint8_t result;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "lock cmpxchg [%1], %3\n\t"   // Compare RAX with [ptr], swap if equal
        "sete %0\n\t"                 // Set byte if equal (ZF=1)
        ".att_syntax prefix"
        : "=q" (result), "+m" (*ptr)
        : "a" (old_val), "r" (new_val)
        : "memory"
    );
    
    return result;
}

uint64_t atomic_exchange_intel(uint64_t *ptr, uint64_t new_val) {
    uint64_t old_val = new_val;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "xchg [%1], %0\n\t"           // Exchange (implicitly locked)
        ".att_syntax prefix"
        : "+r" (old_val), "+m" (*ptr)
        :
        : "memory"
    );
    
    return old_val;
}

/*
 * ============================================================================
 * CPU IDENTIFICATION - Intel Syntax
 * ============================================================================
 */

void cpuid_intel(uint32_t leaf, uint32_t *eax, uint32_t *ebx, 
                 uint32_t *ecx, uint32_t *edx) {
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "cpuid\n\t"
        ".att_syntax prefix"
        : "=a" (*eax), "=b" (*ebx), "=c" (*ecx), "=d" (*edx)
        : "a" (leaf)
    );
}

void get_cpu_vendor_intel(char vendor[13]) {
    uint32_t eax, ebx, ecx, edx;
    
    cpuid_intel(0, &eax, &ebx, &ecx, &edx);
    
    ((uint32_t *)vendor)[0] = ebx;
    ((uint32_t *)vendor)[1] = edx;
    ((uint32_t *)vendor)[2] = ecx;
    vendor[12] = '\0';
}

/*
 * ============================================================================
 * PERFORMANCE COUNTERS - Intel Syntax
 * ============================================================================
 */

uint64_t rdtsc_intel(void) {
    uint32_t lo, hi;
    
    __asm__ __volatile__ (
        ".intel_syntax noprefix\n\t"
        "rdtsc\n\t"                   // Read time-stamp counter
        ".att_syntax prefix"
        : "=a" (lo), "=d" (hi)
    );
    
    return ((uint64_t)hi << 32) | lo;
}

uint64_t rdtsc_serialized_intel(void) {
    uint32_t lo, hi;
    
    __asm__ __volatile__ (
        ".intel_syntax noprefix\n\t"
        "cpuid\n\t"                   // Serialize
        "rdtsc\n\t"
        ".att_syntax prefix"
        : "=a" (lo), "=d" (hi)
        :
        : "rbx", "rcx"
    );
    
    return ((uint64_t)hi << 32) | lo;
}

/*
 * ============================================================================
 * SIMD OPERATIONS - Intel Syntax
 * ============================================================================
 */

void vector_add_intel(float *result, const float *a, const float *b, size_t n) {
    size_t i;
    
    // Process 4 floats at a time
    for (i = 0; i + 4 <= n; i += 4) {
        __asm__ (
            ".intel_syntax noprefix\n\t"
            "movups xmm0, [%1]\n\t"   // Load from a
            "movups xmm1, [%2]\n\t"   // Load from b
            "addps xmm0, xmm1\n\t"    // Add vectors
            "movups [%0], xmm0\n\t"   // Store result
            ".att_syntax prefix"
            :
            : "r" (result + i), "r" (a + i), "r" (b + i)
            : "xmm0", "xmm1", "memory"
        );
    }
    
    // Handle remaining elements
    for (; i < n; i++) {
        result[i] = a[i] + b[i];
    }
}

float dot_product_intel(const float *a, const float *b, size_t n) {
    float result = 0.0f;
    size_t i = 0;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "xorps xmm2, xmm2\n\t"        // Zero accumulator
        "1:\n\t"                      // Loop label
        "cmp %2, 4\n\t"               // Check if n >= 4
        "jl 2f\n\t"                   // Exit if n < 4
        "movups xmm0, [%0]\n\t"       // Load from a
        "movups xmm1, [%1]\n\t"       // Load from b
        "mulps xmm0, xmm1\n\t"        // Multiply
        "addps xmm2, xmm0\n\t"        // Accumulate
        "add %0, 16\n\t"              // Advance pointer (4 floats * 4 bytes)
        "add %1, 16\n\t"
        "sub %2, 4\n\t"               // Decrement count
        "jmp 1b\n\t"
        "2:\n\t"                      // Reduce label
        // Horizontal sum
        "movaps xmm0, xmm2\n\t"
        "shufps xmm0, xmm0, 0x4E\n\t" // Swap halves
        "addps xmm2, xmm0\n\t"
        "movaps xmm0, xmm2\n\t"
        "shufps xmm0, xmm0, 0xB1\n\t" // Swap pairs
        "addps xmm2, xmm0\n\t"
        "movss %3, xmm2\n\t"          // Extract result
        ".att_syntax prefix"
        : "+r" (a), "+r" (b), "+r" (n), "=m" (result)
        :
        : "xmm0", "xmm1", "xmm2", "memory"
    );
    
    // Handle remaining elements
    for (; i < n; i++) {
        result += a[i] * b[i];
    }
    
    return result;
}

/*
 * ============================================================================
 * MEMORY ADDRESSING - Intel Syntax Examples
 * ============================================================================
 */

void array_access_intel(void) {
    int array[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    int index = 3;
    int value;
    
    // Access array[3] using Intel syntax addressing
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "mov eax, [%1 + %2*4]\n\t"    // array[index], scale by 4 (sizeof(int))
        "mov %0, eax\n\t"
        ".att_syntax prefix"
        : "=r" (value)
        : "r" (array), "r" ((long)index)
        : "eax"
    );
    
    printf("array[%d] = %d\n", index, value);
}

/*
 * ============================================================================
 * SYSTEM CALLS - Intel Syntax
 * ============================================================================
 */

ssize_t write_syscall_intel(int fd, const void *buf, size_t count) {
    ssize_t ret;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "mov rax, 1\n\t"              // SYS_write
        "syscall\n\t"
        ".att_syntax prefix"
        : "=a" (ret)
        : "D" (fd), "S" (buf), "d" (count)
        : "rcx", "r11", "memory"
    );
    
    return ret;
}

/*
 * ============================================================================
 * CONDITIONAL OPERATIONS - Intel Syntax
 * ============================================================================
 */

int max_intel(int a, int b) {
    int result;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "mov %0, %1\n\t"              // result = a
        "cmp %0, %2\n\t"              // Compare result with b
        "cmovl %0, %2\n\t"            // If result < b, result = b
        ".att_syntax prefix"
        : "=r" (result)
        : "r" (a), "r" (b)
    );
    
    return result;
}

int min_intel(int a, int b) {
    int result;
    
    __asm__ (
        ".intel_syntax noprefix\n\t"
        "mov %0, %1\n\t"              // result = a
        "cmp %0, %2\n\t"              // Compare result with b
        "cmovg %0, %2\n\t"            // If result > b, result = b
        ".att_syntax prefix"
        : "=r" (result)
        : "r" (a), "r" (b)
    );
    
    return result;
}

/*
 * ============================================================================
 * MAIN FUNCTION - DEMONSTRATIONS
 * ============================================================================
 */

int main(void) {
    printf("=== Intel Syntax Inline Assembly Demonstrations ===\n\n");
    
    // Basic arithmetic
    printf("Arithmetic Operations:\n");
    printf("  add_intel(10, 20) = %lu\n", add_intel_explicit(10, 20));
    printf("  multiply_intel(5, 7) = %lu\n", multiply_intel(5, 7));
    printf("  subtract_intel(100, 42) = %lu\n", subtract_intel(100, 42));
    printf("\n");
    
    // Comparison with AT&T
    printf("Syntax Comparison (both return same result):\n");
    printf("  subtract_att(100, 42) = %lu\n", subtract_att(100, 42));
    printf("  subtract_intel(100, 42) = %lu\n", subtract_intel(100, 42));
    printf("\n");
    
    // Bit manipulation
    uint64_t value = 0x00FF000000000000ULL;
    printf("Bit Manipulation on 0x%016lX:\n", value);
    printf("  Leading zeros: %d\n", count_leading_zeros_intel(value));
    printf("  Population count: %d\n", popcount_intel(0x123456789ABCDEFULL));
    printf("\n");
    
    // CPU info
    char vendor[13];
    get_cpu_vendor_intel(vendor);
    printf("CPU Vendor: %s\n\n", vendor);
    
    // Timing
    uint64_t start = rdtsc_serialized_intel();
    volatile int x = 0;
    for (int i = 0; i < 1000000; i++) {
        x += i;
    }
    uint64_t end = rdtsc_serialized_intel();
    printf("Cycles elapsed: %lu\n\n", end - start);
    
    // Atomic operations
    int64_t counter = 100;
    atomic_increment_intel(&counter);
    printf("Atomic Operations:\n");
    printf("  After increment: %ld\n", counter);
    
    uint64_t old = 101;
    int cas_result = compare_and_swap_intel(&counter, old, 200);
    printf("  CAS result: %s (value = %ld)\n\n", cas_result ? "Success" : "Failed", counter);
    
    // SIMD operations
    float a[] = {1.0f, 2.0f, 3.0f, 4.0f};
    float b[] = {5.0f, 6.0f, 7.0f, 8.0f};
    float result[4];
    
    vector_add_intel(result, a, b, 4);
    printf("SIMD Vector Operations:\n");
    printf("  [%.1f, %.1f, %.1f, %.1f] + [%.1f, %.1f, %.1f, %.1f] = "
           "[%.1f, %.1f, %.1f, %.1f]\n",
           a[0], a[1], a[2], a[3],
           b[0], b[1], b[2], b[3],
           result[0], result[1], result[2], result[3]);
    
    float dot = dot_product_intel(a, b, 4);
    printf("  Dot product: %.1f\n\n", dot);
    
    // Min/Max
    printf("Conditional Operations:\n");
    printf("  max(15, 42) = %d\n", max_intel(15, 42));
    printf("  min(15, 42) = %d\n\n", min_intel(15, 42));
    
    // Array access
    printf("Memory Addressing:\n");
    array_access_intel();
    
    printf("\n=== All Intel syntax tests completed ===\n");
    
    return 0;
}

/*
 * ============================================================================
 * NOTES: Intel vs AT&T Syntax
 * ============================================================================
 * 
 * Intel Syntax Advantages:
 *   ✓ Matches Intel/AMD documentation
 *   ✓ Destination-first feels more natural (like x = y)
 *   ✓ No prefix clutter (%, $)
 *   ✓ Cleaner memory addressing syntax
 * 
 * AT&T Syntax Advantages:
 *   ✓ Default for GCC/GAS
 *   ✓ More explicit (prefixes prevent ambiguity)
 *   ✓ Unix tradition
 *   ✓ Size suffix on instruction is clearer
 * 
 * Switching Between Syntaxes:
 *   - Use .intel_syntax noprefix / .att_syntax prefix directives
 *   - Or compile with -masm=intel flag
 *   - Can mix both in same file if needed
 * 
 * Best Practice:
 *   - Choose one syntax per project and stick with it
 *   - Document which syntax you're using
 *   - Intel syntax is more common in tutorials/disassemblers
 *   - AT&T syntax is more common in Unix/Linux source code
 * 
 * Memory Addressing Comparison:
 *   Intel: [base + index*scale + disp]
 *   AT&T:  disp(base, index, scale)
 *   
 *   Example - array[i] where array is in RBX, i in RCX:
 *   Intel: mov eax, [rbx + rcx*4 + 0]
 *   AT&T:  movl 0(%rbx,%rcx,4), %eax
 * 
 * Operand Reference (%0, %1, etc.) works the same in both syntaxes!
 * 
 * ============================================================================
 */

