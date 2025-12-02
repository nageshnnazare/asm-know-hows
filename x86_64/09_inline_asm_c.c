/*
 * ============================================================================
 * File: 09_inline_asm_c.c
 * Description: Inline assembly in C (GCC extended asm syntax)
 * Topics: Inline asm, constraints, clobbers, optimization
 * Compiler: GCC
 * Build: gcc -O2 09_inline_asm_c.c -o 09_inline_asm_c
 * ============================================================================
 */

#include <stdio.h>
#include <stdint.h>

/*
 * ============================================================================
 * BASIC INLINE ASSEMBLY
 * ============================================================================
 */

uint64_t basic_add(uint64_t a, uint64_t b) {
    uint64_t result;
    
    // Basic inline assembly syntax:
    // asm("assembly code" : outputs : inputs : clobbers);
    
    __asm__ (
        "movq %1, %0\n\t"      // Move first input to output
        "addq %2, %0\n\t"      // Add second input to output
        : "=r" (result)        // Output: %0 = result (any register)
        : "r" (a), "r" (b)     // Inputs: %1 = a, %2 = b (any registers)
    );
    
    return result;
}

/*
 * ============================================================================
 * SPECIFIC REGISTER CONSTRAINTS
 * ============================================================================
 */

uint64_t multiply_rax(uint64_t a, uint64_t b) {
    uint64_t result;
    
    __asm__ (
        "movq %1, %%rax\n\t"
        "imulq %2\n\t"
        "movq %%rax, %0\n\t"
        : "=r" (result)
        : "r" (a), "r" (b)
        : "rax", "rdx"         // Clobber list: these registers are modified
    );
    
    return result;
}

/*
 * ============================================================================
 * CONSTRAINT REFERENCE
 * ============================================================================
 * 
 * Register Constraints:
 *   "r" - Any general purpose register
 *   "a" - RAX/EAX/AX/AL
 *   "b" - RBX/EBX/BX/BL
 *   "c" - RCX/ECX/CX/CL
 *   "d" - RDX/EDX/DX/DL
 *   "S" - RSI/ESI/SI/SIL
 *   "D" - RDI/EDI/DI/DIL
 *   "x" - Any XMM register
 * 
 * Memory Constraints:
 *   "m" - Memory operand
 * 
 * Immediate Constraints:
 *   "i" - Immediate integer constant
 *   "I" - Immediate integer 0-31
 *   "n" - Immediate integer with known value
 * 
 * Output Modifiers:
 *   "=" - Write-only operand
 *   "+" - Read-write operand
 *   "&" - Early clobber (written before inputs read)
 * 
 * ============================================================================
 */

/*
 * ============================================================================
 * MEMORY OPERATIONS
 * ============================================================================
 */

void copy_memory_asm(void *dest, const void *src, size_t n) {
    __asm__ (
        "cld\n\t"              // Clear direction flag
        "rep movsb\n\t"        // Repeat move string byte
        : "+D" (dest),         // +D: read-write, RDI register
          "+S" (src),          // +S: read-write, RSI register
          "+c" (n)             // +c: read-write, RCX register
        :
        : "memory"             // Clobber: memory is modified
    );
}

void fill_memory_asm(void *dest, uint8_t value, size_t n) {
    __asm__ (
        "cld\n\t"
        "rep stosb\n\t"
        : "+D" (dest), "+c" (n)
        : "a" (value)          // AL register
        : "memory"
    );
}

/*
 * ============================================================================
 * BIT MANIPULATION
 * ============================================================================
 */

// Count leading zeros
int count_leading_zeros(uint64_t x) {
    int count;
    
    if (x == 0)
        return 64;
    
    __asm__ (
        "bsrq %1, %0\n\t"      // Bit scan reverse (find highest set bit)
        "xorq $63, %0\n\t"     // Convert to leading zeros
        : "=r" (count)
        : "r" (x)
    );
    
    return count;
}

// Count trailing zeros
int count_trailing_zeros(uint64_t x) {
    int count;
    
    if (x == 0)
        return 64;
    
    __asm__ (
        "bsfq %1, %0\n\t"      // Bit scan forward (find lowest set bit)
        : "=r" (count)
        : "r" (x)
    );
    
    return count;
}

// Population count (number of 1 bits)
int popcount(uint64_t x) {
    int count;
    
    __asm__ (
        "popcntq %1, %0\n\t"   // Population count (requires POPCNT instruction)
        : "=r" (count)
        : "r" (x)
    );
    
    return count;
}

/*
 * ============================================================================
 * ATOMIC OPERATIONS
 * ============================================================================
 */

// Atomic increment
void atomic_increment(int64_t *ptr) {
    __asm__ (
        "lock incq %0\n\t"     // Lock prefix for atomicity
        : "+m" (*ptr)          // Memory operand, read-write
        :
        : "memory"             // Prevent reordering
    );
}

// Compare and swap (CAS)
int compare_and_swap(uint64_t *ptr, uint64_t old_val, uint64_t new_val) {
    uint8_t result;
    
    __asm__ (
        "lock cmpxchgq %2, %0\n\t"  // Compare RAX with [ptr], swap if equal
        "sete %1\n\t"               // Set byte if equal (success)
        : "+m" (*ptr), "=q" (result)
        : "r" (new_val), "a" (old_val)
        : "memory"
    );
    
    return result;
}

// Atomic exchange
uint64_t atomic_exchange(uint64_t *ptr, uint64_t new_val) {
    uint64_t old_val;
    
    __asm__ (
        "xchgq %0, %1\n\t"     // Exchange (implicitly atomic)
        : "=r" (old_val), "+m" (*ptr)
        : "0" (new_val)
        : "memory"
    );
    
    return old_val;
}

/*
 * ============================================================================
 * CPU IDENTIFICATION AND FEATURES
 * ============================================================================
 */

void cpuid(uint32_t leaf, uint32_t *eax, uint32_t *ebx, 
           uint32_t *ecx, uint32_t *edx) {
    __asm__ (
        "cpuid\n\t"
        : "=a" (*eax), "=b" (*ebx), "=c" (*ecx), "=d" (*edx)
        : "a" (leaf)
    );
}

void get_cpu_vendor(char vendor[13]) {
    uint32_t eax, ebx, ecx, edx;
    
    cpuid(0, &eax, &ebx, &ecx, &edx);
    
    // Vendor string is in EBX, EDX, ECX
    ((uint32_t *)vendor)[0] = ebx;
    ((uint32_t *)vendor)[1] = edx;
    ((uint32_t *)vendor)[2] = ecx;
    vendor[12] = '\0';
}

/*
 * ============================================================================
 * PERFORMANCE COUNTERS
 * ============================================================================
 */

// Read Time-Stamp Counter
uint64_t rdtsc(void) {
    uint32_t lo, hi;
    
    __asm__ __volatile__ (
        "rdtsc\n\t"
        : "=a" (lo), "=d" (hi)
    );
    
    return ((uint64_t)hi << 32) | lo;
}

// Read Time-Stamp Counter with serialization
uint64_t rdtsc_serialized(void) {
    uint32_t lo, hi;
    
    __asm__ __volatile__ (
        "cpuid\n\t"            // Serialize (wait for all previous instructions)
        "rdtsc\n\t"
        : "=a" (lo), "=d" (hi)
        :
        : "rbx", "rcx"
    );
    
    return ((uint64_t)hi << 32) | lo;
}

/*
 * ============================================================================
 * SIMD OPERATIONS
 * ============================================================================
 */

// Vector addition using SSE
void vector_add_sse(float *result, const float *a, const float *b, size_t n) {
    size_t i;
    
    // Process 4 floats at a time
    for (i = 0; i + 4 <= n; i += 4) {
        __asm__ (
            "movups (%1), %%xmm0\n\t"      // Load 4 floats from a
            "movups (%2), %%xmm1\n\t"      // Load 4 floats from b
            "addps %%xmm1, %%xmm0\n\t"     // Add vectors
            "movups %%xmm0, (%0)\n\t"      // Store result
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

// Dot product using SSE
float dot_product_sse(const float *a, const float *b, size_t n) {
    float result = 0.0f;
    size_t i;
    
    __asm__ (
        "xorps %%xmm2, %%xmm2\n\t"         // Zero accumulator
        "1:\n\t"                            // Loop label
        "cmpq $4, %2\n\t"                   // Check if n >= 4
        "jl 2f\n\t"                         // Exit loop if n < 4
        "movups (%0), %%xmm0\n\t"          // Load 4 floats from a
        "movups (%1), %%xmm1\n\t"          // Load 4 floats from b
        "mulps %%xmm1, %%xmm0\n\t"         // Multiply
        "addps %%xmm0, %%xmm2\n\t"         // Accumulate
        "addq $16, %0\n\t"                 // Advance pointers
        "addq $16, %1\n\t"
        "subq $4, %2\n\t"                  // Decrement count
        "jmp 1b\n\t"
        "2:\n\t"                            // Reduce label
        // Horizontal sum of xmm2
        "movaps %%xmm2, %%xmm0\n\t"
        "shufps $0x4E, %%xmm0, %%xmm0\n\t"
        "addps %%xmm0, %%xmm2\n\t"
        "movaps %%xmm2, %%xmm0\n\t"
        "shufps $0xB1, %%xmm0, %%xmm0\n\t"
        "addps %%xmm0, %%xmm2\n\t"
        "movss %%xmm2, %3\n\t"             // Extract result
        : "+r" (a), "+r" (b), "+r" (n), "=m" (result)
        :
        : "xmm0", "xmm1", "xmm2", "memory"
    );
    
    // Handle remaining elements
    for (i = 0; i < n; i++) {
        result += a[i] * b[i];
    }
    
    return result;
}

/*
 * ============================================================================
 * VOLATILE ASSEMBLY (Prevents Optimization)
 * ============================================================================
 */

// Prevent compiler from optimizing away code
void do_not_optimize_away(void *ptr) {
    __asm__ __volatile__ ("" : : "r,m" (ptr) : "memory");
}

// Memory barrier (prevent reordering)
void memory_barrier(void) {
    __asm__ __volatile__ ("mfence" ::: "memory");
}

// Compiler barrier (prevent compiler reordering)
void compiler_barrier(void) {
    __asm__ __volatile__ ("" ::: "memory");
}

/*
 * ============================================================================
 * SYSTEM CALLS FROM INLINE ASM
 * ============================================================================
 */

ssize_t write_syscall(int fd, const void *buf, size_t count) {
    ssize_t ret;
    
    __asm__ (
        "movq $1, %%rax\n\t"       // sys_write
        "syscall\n\t"
        : "=a" (ret)
        : "D" (fd), "S" (buf), "d" (count)
        : "rcx", "r11", "memory"   // Syscall clobbers RCX and R11
    );
    
    return ret;
}

/*
 * ============================================================================
 * MAIN FUNCTION - DEMONSTRATIONS
 * ============================================================================
 */

int main(void) {
    printf("=== Inline Assembly Demonstrations ===\n\n");
    
    // Basic arithmetic
    uint64_t sum = basic_add(10, 20);
    printf("Basic add: 10 + 20 = %lu\n", sum);
    
    // Bit manipulation
    uint64_t value = 0x00FF000000000000ULL;
    printf("\nBit manipulation on 0x%016lX:\n", value);
    printf("  Leading zeros:  %d\n", count_leading_zeros(value));
    printf("  Trailing zeros: %d\n", count_trailing_zeros(value));
    
    value = 0x123456789ABCDEFULL;
    printf("  Population count of 0x%016lX: %d\n", value, popcount(value));
    
    // CPU information
    char vendor[13];
    get_cpu_vendor(vendor);
    printf("\nCPU Vendor: %s\n", vendor);
    
    // Timing
    uint64_t start = rdtsc_serialized();
    // Do some work
    volatile int x = 0;
    for (int i = 0; i < 1000000; i++) {
        x += i;
    }
    uint64_t end = rdtsc_serialized();
    printf("Cycles elapsed: %lu\n", end - start);
    
    // Atomic operations
    int64_t counter = 100;
    atomic_increment(&counter);
    printf("\nAtomic increment: 100 -> %ld\n", counter);
    
    uint64_t old_value = 101;
    uint64_t new_value = 200;
    int cas_result = compare_and_swap(&counter, old_value, new_value);
    printf("Compare and swap: %s (value = %ld)\n", 
           cas_result ? "Success" : "Failed", counter);
    
    // SIMD vector addition
    float a[] = {1.0f, 2.0f, 3.0f, 4.0f};
    float b[] = {5.0f, 6.0f, 7.0f, 8.0f};
    float result[4];
    
    vector_add_sse(result, a, b, 4);
    printf("\nSIMD Vector addition:\n");
    printf("  [%.1f, %.1f, %.1f, %.1f] + [%.1f, %.1f, %.1f, %.1f] = "
           "[%.1f, %.1f, %.1f, %.1f]\n",
           a[0], a[1], a[2], a[3],
           b[0], b[1], b[2], b[3],
           result[0], result[1], result[2], result[3]);
    
    float dot = dot_product_sse(a, b, 4);
    printf("  Dot product: %.1f\n", dot);
    
    printf("\n=== All tests completed ===\n");
    
    return 0;
}

/*
 * ============================================================================
 * NOTES ON INLINE ASSEMBLY
 * ============================================================================
 * 
 * Syntax:
 *   asm [volatile] ("assembly code"
 *                   : output operands
 *                   : input operands
 *                   : clobber list);
 * 
 * Operand References:
 *   %0, %1, %2, ... - Operands in order (outputs first, then inputs)
 *   %% - Literal % in assembly code
 * 
 * When to Use Inline Assembly:
 *   ✓ Access special CPU instructions
 *   ✓ Optimize critical paths
 *   ✓ Implement system calls
 *   ✓ Atomic operations
 *   ✓ Low-level hardware access
 * 
 * When NOT to Use:
 *   ✗ Regular code (compiler often does better)
 *   ✗ Portable code (inline asm is not portable)
 *   ✗ Complex algorithms (hard to maintain)
 * 
 * Best Practices:
 *   1. Use intrinsics when available (e.g., _mm_add_ps for SSE)
 *   2. Mark volatile if has side effects
 *   3. Specify all clobbers correctly
 *   4. Keep inline asm minimal
 *   5. Document what the code does
 *   6. Test with optimizations enabled
 *   7. Check compiler output (gcc -S)
 * 
 * Common Pitfalls:
 *   - Forgetting clobber list
 *   - Not marking volatile when needed
 *   - Incorrect constraints
 *   - Register conflicts
 *   - Assuming register allocation
 * 
 * Performance Considerations:
 *   - Inline asm can prevent optimizations
 *   - Compiler can't optimize across inline asm
 *   - May hurt register allocation
 *   - Use only when necessary
 * 
 * ============================================================================
 */

