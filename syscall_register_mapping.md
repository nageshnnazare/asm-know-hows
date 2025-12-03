# Syscall Register Mapping Reference

This document provides detailed syscall mappings showing register usage and parameter names for x86-64, x86 (32-bit), ARM64, and ARM (32-bit) architectures.

---

## x86-64 (64-bit) Linux Syscalls

### Register Convention
- **Syscall Number**: `%rax`
- **Arguments**: `%rdi`, `%rsi`, `%rdx`, `%r10`, `%r8`, `%r9`
- **Return Value**: `%rax`
- **Instruction**: `syscall`

### Common Syscalls

| %rax | System call | %rdi | %rsi | %rdx | %r10 | %r8 | %r9 |
|------|-------------|------|------|------|------|-----|-----|
| 0 | sys_read | unsigned int fd | char *buf | size_t count | | | |
| 1 | sys_write | unsigned int fd | const char *buf | size_t count | | | |
| 2 | sys_open | const char *filename | int flags | umode_t mode | | | |
| 3 | sys_close | unsigned int fd | | | | | |
| 4 | sys_stat | const char *filename | struct stat *statbuf | | | | |
| 5 | sys_fstat | unsigned int fd | struct stat *statbuf | | | | |
| 6 | sys_lstat | const char *filename | struct stat *statbuf | | | | |
| 7 | sys_poll | struct pollfd *ufds | unsigned int nfds | int timeout | | | |
| 8 | sys_lseek | unsigned int fd | off_t offset | unsigned int whence | | | |
| 9 | sys_mmap | unsigned long addr | unsigned long len | unsigned long prot | unsigned long flags | unsigned long fd | unsigned long off |
| 10 | sys_mprotect | unsigned long start | size_t len | unsigned long prot | | | |
| 11 | sys_munmap | unsigned long addr | size_t len | | | | |
| 12 | sys_brk | unsigned long brk | | | | | |
| 13 | sys_rt_sigaction | int sig | const struct sigaction *act | struct sigaction *oact | size_t sigsetsize | | |
| 14 | sys_rt_sigprocmask | int how | sigset_t *set | sigset_t *oset | size_t sigsetsize | | |
| 15 | sys_rt_sigreturn | | | | | | |
| 16 | sys_ioctl | unsigned int fd | unsigned int cmd | unsigned long arg | | | |
| 17 | sys_pread64 | unsigned int fd | char *buf | size_t count | loff_t pos | | |
| 18 | sys_pwrite64 | unsigned int fd | const char *buf | size_t count | loff_t pos | | |
| 19 | sys_readv | unsigned long fd | const struct iovec *vec | unsigned long vlen | | | |
| 20 | sys_writev | unsigned long fd | const struct iovec *vec | unsigned long vlen | | | |
| 21 | sys_access | const char *filename | int mode | | | | |
| 22 | sys_pipe | int *fildes | | | | | |
| 23 | sys_select | int n | fd_set *inp | fd_set *outp | fd_set *exp | struct timeval *tvp | |
| 24 | sys_sched_yield | | | | | | |
| 25 | sys_mremap | unsigned long addr | unsigned long old_len | unsigned long new_len | unsigned long flags | unsigned long new_addr | |
| 26 | sys_msync | unsigned long start | size_t len | int flags | | | |
| 27 | sys_mincore | unsigned long start | size_t len | unsigned char *vec | | | |
| 28 | sys_madvise | unsigned long start | size_t len | int behavior | | | |
| 32 | sys_dup | unsigned int fildes | | | | | |
| 33 | sys_dup2 | unsigned int oldfd | unsigned int newfd | | | | |
| 34 | sys_pause | | | | | | |
| 35 | sys_nanosleep | struct timespec *rqtp | struct timespec *rmtp | | | | |
| 37 | sys_alarm | unsigned int seconds | | | | | |
| 39 | sys_getpid | | | | | | |
| 41 | sys_socket | int family | int type | int protocol | | | |
| 42 | sys_connect | int fd | struct sockaddr *uservaddr | int addrlen | | | |
| 43 | sys_accept | int fd | struct sockaddr *upeer_sockaddr | int *upeer_addrlen | | | |
| 44 | sys_sendto | int fd | void *buff | size_t len | unsigned flags | struct sockaddr *addr | int addr_len |
| 45 | sys_recvfrom | int fd | void *ubuf | size_t size | unsigned flags | struct sockaddr *addr | int *addr_len |
| 46 | sys_sendmsg | int fd | struct msghdr *msg | unsigned flags | | | |
| 47 | sys_recvmsg | int fd | struct msghdr *msg | unsigned flags | | | |
| 48 | sys_shutdown | int fd | int how | | | | |
| 49 | sys_bind | int fd | struct sockaddr *umyaddr | int addrlen | | | |
| 50 | sys_listen | int fd | int backlog | | | | |
| 51 | sys_getsockname | int fd | struct sockaddr *usockaddr | int *usockaddr_len | | | |
| 52 | sys_getpeername | int fd | struct sockaddr *usockaddr | int *usockaddr_len | | | |
| 53 | sys_socketpair | int family | int type | int protocol | int *usockvec | | |
| 54 | sys_setsockopt | int fd | int level | int optname | char *optval | int optlen | |
| 55 | sys_getsockopt | int fd | int level | int optname | char *optval | int *optlen | |
| 56 | sys_clone | unsigned long flags | unsigned long newsp | int *parent_tidptr | int *child_tidptr | unsigned long tls | |
| 57 | sys_fork | | | | | | |
| 58 | sys_vfork | | | | | | |
| 59 | sys_execve | const char *filename | const char *const *argv | const char *const *envp | | | |
| 60 | sys_exit | int error_code | | | | | |
| 61 | sys_wait4 | pid_t pid | int *stat_addr | int options | struct rusage *ru | | |
| 62 | sys_kill | pid_t pid | int sig | | | | |
| 63 | sys_uname | struct old_utsname *name | | | | | |
| 78 | sys_getdents | unsigned int fd | struct linux_dirent *dirent | unsigned int count | | | |
| 79 | sys_getcwd | char *buf | unsigned long size | | | | |
| 80 | sys_chdir | const char *filename | | | | | |
| 81 | sys_fchdir | unsigned int fd | | | | | |
| 82 | sys_rename | const char *oldname | const char *newname | | | | |
| 83 | sys_mkdir | const char *pathname | umode_t mode | | | | |
| 84 | sys_rmdir | const char *pathname | | | | | |
| 85 | sys_creat | const char *pathname | umode_t mode | | | | |
| 86 | sys_link | const char *oldname | const char *newname | | | | |
| 87 | sys_unlink | const char *pathname | | | | | |
| 88 | sys_symlink | const char *oldname | const char *newname | | | | |
| 89 | sys_readlink | const char *path | char *buf | int bufsiz | | | |
| 90 | sys_chmod | const char *filename | umode_t mode | | | | |
| 91 | sys_fchmod | unsigned int fd | umode_t mode | | | | |
| 92 | sys_chown | const char *filename | uid_t user | gid_t group | | | |
| 93 | sys_fchown | unsigned int fd | uid_t user | gid_t group | | | |
| 94 | sys_lchown | const char *filename | uid_t user | gid_t group | | | |
| 95 | sys_umask | int mask | | | | | |
| 96 | sys_gettimeofday | struct timeval *tv | struct timezone *tz | | | | |
| 102 | sys_getuid | | | | | | |
| 104 | sys_getgid | | | | | | |
| 105 | sys_setuid | uid_t uid | | | | | |
| 106 | sys_setgid | gid_t gid | | | | | |
| 107 | sys_geteuid | | | | | | |
| 108 | sys_getegid | | | | | | |

---

## x86 (32-bit) Linux Syscalls

### Register Convention
- **Syscall Number**: `%eax`
- **Arguments**: `%ebx`, `%ecx`, `%edx`, `%esi`, `%edi`, `%ebp`
- **Return Value**: `%eax`
- **Instruction**: `int $0x80`

### Common Syscalls

| %eax | System call | %ebx | %ecx | %edx | %esi | %edi | %ebp |
|------|-------------|------|------|------|------|------|------|
| 1 | sys_exit | int error_code | | | | | |
| 2 | sys_fork | | | | | | |
| 3 | sys_read | unsigned int fd | char *buf | size_t count | | | |
| 4 | sys_write | unsigned int fd | const char *buf | size_t count | | | |
| 5 | sys_open | const char *filename | int flags | umode_t mode | | | |
| 6 | sys_close | unsigned int fd | | | | | |
| 7 | sys_waitpid | pid_t pid | int *stat_addr | int options | | | |
| 8 | sys_creat | const char *pathname | umode_t mode | | | | |
| 9 | sys_link | const char *oldname | const char *newname | | | | |
| 10 | sys_unlink | const char *pathname | | | | | |
| 11 | sys_execve | const char *filename | const char *const *argv | const char *const *envp | | | |
| 12 | sys_chdir | const char *filename | | | | | |
| 13 | sys_time | time_t *tloc | | | | | |
| 14 | sys_mknod | const char *filename | umode_t mode | unsigned dev | | | |
| 15 | sys_chmod | const char *filename | umode_t mode | | | | |
| 19 | sys_lseek | unsigned int fd | off_t offset | unsigned int whence | | | |
| 20 | sys_getpid | | | | | | |
| 33 | sys_access | const char *filename | int mode | | | | |
| 37 | sys_kill | pid_t pid | int sig | | | | |
| 39 | sys_mkdir | const char *pathname | umode_t mode | | | | |
| 40 | sys_rmdir | const char *pathname | | | | | |
| 41 | sys_dup | unsigned int fildes | | | | | |
| 42 | sys_pipe | int *fildes | | | | | |
| 45 | sys_brk | unsigned long brk | | | | | |
| 54 | sys_ioctl | unsigned int fd | unsigned int cmd | unsigned long arg | | | |
| 85 | sys_readlink | const char *path | char *buf | int bufsiz | | | |
| 90 | sys_mmap | unsigned long addr | unsigned long len | unsigned long prot | unsigned long flags | unsigned long fd | unsigned long off |
| 91 | sys_munmap | unsigned long addr | size_t len | | | | |
| 102 | sys_socketcall | int call | unsigned long *args | | | | |
| 120 | sys_clone | unsigned long flags | unsigned long newsp | int *parent_tidptr | int *child_tidptr | unsigned long tls | |
| 122 | sys_uname | struct old_utsname *name | | | | | |
| 141 | sys_getdents | unsigned int fd | struct linux_dirent *dirent | unsigned int count | | | |
| 162 | sys_nanosleep | struct timespec *rqtp | struct timespec *rmtp | | | | |
| 183 | sys_getcwd | char *buf | unsigned long size | | | | |
| 192 | sys_mmap2 | unsigned long addr | unsigned long len | unsigned long prot | unsigned long flags | unsigned long fd | unsigned long pgoffset |
| 195 | sys_stat64 | const char *filename | struct stat64 *statbuf | | | | |
| 197 | sys_fstat64 | unsigned long fd | struct stat64 *statbuf | | | | |
| 199 | sys_getuid32 | | | | | | |
| 200 | sys_getgid32 | | | | | | |
| 201 | sys_geteuid32 | | | | | | |
| 202 | sys_getegid32 | | | | | | |
| 240 | sys_futex | u32 *uaddr | int op | u32 val | struct timespec *utime | u32 *uaddr2 | u32 val3 |
| 252 | sys_exit_group | int error_code | | | | | |

---

## ARM64 / AArch64 Linux Syscalls

### Register Convention
- **Syscall Number**: `x8`
- **Arguments**: `x0`, `x1`, `x2`, `x3`, `x4`, `x5`
- **Return Value**: `x0`
- **Instruction**: `svc #0`

### Common Syscalls

| x8 | System call | x0 | x1 | x2 | x3 | x4 | x5 |
|----|-------------|----|----|----|----|----|----|
| 56 | sys_openat | int dfd | const char *filename | int flags | umode_t mode | | |
| 57 | sys_close | unsigned int fd | | | | | |
| 61 | sys_getdents64 | unsigned int fd | struct linux_dirent64 *dirent | unsigned int count | | | |
| 62 | sys_lseek | unsigned int fd | off_t offset | unsigned int whence | | | |
| 63 | sys_read | unsigned int fd | char *buf | size_t count | | | |
| 64 | sys_write | unsigned int fd | const char *buf | size_t count | | | |
| 65 | sys_readv | unsigned long fd | const struct iovec *vec | unsigned long vlen | | | |
| 66 | sys_writev | unsigned long fd | const struct iovec *vec | unsigned long vlen | | | |
| 67 | sys_pread64 | unsigned int fd | char *buf | size_t count | loff_t pos | | |
| 68 | sys_pwrite64 | unsigned int fd | const char *buf | size_t count | loff_t pos | | |
| 78 | sys_readlinkat | int dfd | const char *pathname | char *buf | int bufsiz | | |
| 79 | sys_fstatat | int dfd | const char *filename | struct stat *statbuf | int flag | | |
| 80 | sys_fstat | unsigned int fd | struct stat *statbuf | | | | |
| 93 | sys_exit | int error_code | | | | | |
| 94 | sys_exit_group | int error_code | | | | | |
| 96 | sys_set_tid_address | int *tidptr | | | | | |
| 98 | sys_futex | u32 *uaddr | int op | u32 val | struct timespec *utime | u32 *uaddr2 | u32 val3 |
| 99 | sys_set_robust_list | struct robust_list_head *head | size_t len | | | | |
| 101 | sys_nanosleep | struct timespec *rqtp | struct timespec *rmtp | | | | |
| 113 | sys_clock_gettime | clockid_t which_clock | struct timespec *tp | | | | |
| 124 | sys_sched_yield | | | | | | |
| 129 | sys_kill | pid_t pid | int sig | | | | |
| 131 | sys_tgkill | pid_t tgid | pid_t pid | int sig | | | |
| 134 | sys_rt_sigaction | int sig | const struct sigaction *act | struct sigaction *oact | size_t sigsetsize | | |
| 135 | sys_rt_sigprocmask | int how | sigset_t *set | sigset_t *oset | size_t sigsetsize | | |
| 139 | sys_rt_sigreturn | | | | | | |
| 160 | sys_uname | struct old_utsname *name | | | | | |
| 172 | sys_getpid | | | | | | |
| 173 | sys_getppid | | | | | | |
| 174 | sys_getuid | | | | | | |
| 175 | sys_geteuid | | | | | | |
| 176 | sys_getgid | | | | | | |
| 177 | sys_getegid | | | | | | |
| 198 | sys_socket | int family | int type | int protocol | | | |
| 200 | sys_bind | int fd | struct sockaddr *umyaddr | int addrlen | | | |
| 201 | sys_listen | int fd | int backlog | | | | |
| 202 | sys_accept | int fd | struct sockaddr *upeer_sockaddr | int *upeer_addrlen | | | |
| 203 | sys_connect | int fd | struct sockaddr *uservaddr | int addrlen | | | |
| 206 | sys_sendto | int fd | void *buff | size_t len | unsigned flags | struct sockaddr *addr | int addr_len |
| 207 | sys_recvfrom | int fd | void *ubuf | size_t size | unsigned flags | struct sockaddr *addr | int *addr_len |
| 208 | sys_setsockopt | int fd | int level | int optname | char *optval | int optlen | |
| 209 | sys_getsockopt | int fd | int level | int optname | char *optval | int *optlen | |
| 214 | sys_brk | unsigned long brk | | | | | |
| 215 | sys_munmap | unsigned long addr | size_t len | | | | |
| 220 | sys_clone | unsigned long flags | unsigned long newsp | int *parent_tidptr | unsigned long tls | int *child_tidptr | |
| 221 | sys_execve | const char *filename | const char *const *argv | const char *const *envp | | | |
| 222 | sys_mmap | unsigned long addr | unsigned long len | unsigned long prot | unsigned long flags | unsigned long fd | off_t off |
| 226 | sys_mprotect | unsigned long start | size_t len | unsigned long prot | | | |
| 260 | sys_wait4 | pid_t pid | int *stat_addr | int options | struct rusage *ru | | |
| 261 | sys_prlimit64 | pid_t pid | unsigned int resource | const struct rlimit64 *new_rlim | struct rlimit64 *old_rlim | | |
| 269 | sys_faccessat | int dfd | const char *filename | int mode | | | |
| 278 | sys_getrandom | char *buf | size_t count | unsigned int flags | | | |

---

## ARM (32-bit) Linux Syscalls

### Register Convention
- **Syscall Number**: `r7`
- **Arguments**: `r0`, `r1`, `r2`, `r3`, `r4`, `r5`, `r6`
- **Return Value**: `r0`
- **Instruction**: `svc #0` (or `swi #0`)

### Common Syscalls

| r7 | System call | r0 | r1 | r2 | r3 | r4 | r5 | r6 |
|----|-------------|----|----|----|----|----|----|-----|
| 1 | sys_exit | int error_code | | | | | | |
| 2 | sys_fork | | | | | | | |
| 3 | sys_read | unsigned int fd | char *buf | size_t count | | | | |
| 4 | sys_write | unsigned int fd | const char *buf | size_t count | | | | |
| 5 | sys_open | const char *filename | int flags | umode_t mode | | | | |
| 6 | sys_close | unsigned int fd | | | | | | |
| 8 | sys_creat | const char *pathname | umode_t mode | | | | | |
| 9 | sys_link | const char *oldname | const char *newname | | | | | |
| 10 | sys_unlink | const char *pathname | | | | | | |
| 11 | sys_execve | const char *filename | const char *const *argv | const char *const *envp | | | | |
| 12 | sys_chdir | const char *filename | | | | | | |
| 15 | sys_chmod | const char *filename | umode_t mode | | | | | |
| 19 | sys_lseek | unsigned int fd | off_t offset | unsigned int whence | | | | |
| 20 | sys_getpid | | | | | | | |
| 33 | sys_access | const char *filename | int mode | | | | | |
| 37 | sys_kill | pid_t pid | int sig | | | | | |
| 39 | sys_mkdir | const char *pathname | umode_t mode | | | | | |
| 40 | sys_rmdir | const char *pathname | | | | | | |
| 41 | sys_dup | unsigned int fildes | | | | | | |
| 42 | sys_pipe | int *fildes | | | | | | |
| 45 | sys_brk | unsigned long brk | | | | | | |
| 54 | sys_ioctl | unsigned int fd | unsigned int cmd | unsigned long arg | | | | |
| 85 | sys_readlink | const char *path | char *buf | int bufsiz | | | | |
| 90 | sys_mmap | unsigned long addr | unsigned long len | unsigned long prot | unsigned long flags | unsigned long fd | unsigned long off | |
| 91 | sys_munmap | unsigned long addr | size_t len | | | | | |
| 120 | sys_clone | unsigned long flags | unsigned long newsp | int *parent_tidptr | unsigned long tls | int *child_tidptr | | |
| 122 | sys_uname | struct old_utsname *name | | | | | | |
| 141 | sys_getdents | unsigned int fd | struct linux_dirent *dirent | unsigned int count | | | | |
| 162 | sys_nanosleep | struct timespec *rqtp | struct timespec *rmtp | | | | | |
| 183 | sys_getcwd | char *buf | unsigned long size | | | | | |
| 192 | sys_mmap2 | unsigned long addr | unsigned long len | unsigned long prot | unsigned long flags | unsigned long fd | unsigned long pgoffset | |
| 195 | sys_stat64 | const char *filename | struct stat64 *statbuf | | | | | |
| 197 | sys_fstat64 | unsigned long fd | struct stat64 *statbuf | | | | | |
| 199 | sys_getuid32 | | | | | | | |
| 200 | sys_getgid32 | | | | | | | |
| 201 | sys_geteuid32 | | | | | | | |
| 202 | sys_getegid32 | | | | | | | |
| 240 | sys_futex | u32 *uaddr | int op | u32 val | struct timespec *utime | u32 *uaddr2 | u32 val3 | |
| 248 | sys_exit_group | int error_code | | | | | | |
| 281 | sys_socket | int family | int type | int protocol | | | | |
| 282 | sys_bind | int fd | struct sockaddr *umyaddr | int addrlen | | | | |
| 283 | sys_connect | int fd | struct sockaddr *uservaddr | int addrlen | | | | |
| 284 | sys_listen | int fd | int backlog | | | | | |
| 285 | sys_accept | int fd | struct sockaddr *upeer_sockaddr | int *upeer_addrlen | | | | |
| 289 | sys_sendto | int fd | void *buff | size_t len | unsigned flags | struct sockaddr *addr | int addr_len | |
| 290 | sys_recvfrom | int fd | void *ubuf | size_t size | unsigned flags | struct sockaddr *addr | int *addr_len | |
| 294 | sys_setsockopt | int fd | int level | int optname | char *optval | int optlen | | |
| 295 | sys_getsockopt | int fd | int level | int optname | char *optval | int *optlen | | |
| 320 | sys_utimensat | int dfd | const char *filename | struct timespec *utimes | int flags | | | |
| 322 | sys_timerfd_create | int clockid | int flags | | | | | |
| 345 | sys_getrandom | char *buf | size_t count | unsigned int flags | | | | |

---

## Quick Reference Summary

### Syscall Number Register

| Architecture | Register |
|--------------|----------|
| x86-64 | `%rax` |
| x86 (32-bit) | `%eax` |
| ARM64 | `x8` |
| ARM (32-bit) | `r7` |

### Argument Registers

| Arg | x86-64 | x86 (32-bit) | ARM64 | ARM (32-bit) |
|-----|--------|--------------|-------|--------------|
| 1 | `%rdi` | `%ebx` | `x0` | `r0` |
| 2 | `%rsi` | `%ecx` | `x1` | `r1` |
| 3 | `%rdx` | `%edx` | `x2` | `r2` |
| 4 | `%r10` | `%esi` | `x3` | `r3` |
| 5 | `%r8` | `%edi` | `x4` | `r4` |
| 6 | `%r9` | `%ebp` | `x5` | `r5` |
| 7 | — | — | — | `r6` |

### Invocation Instructions

| Architecture | Instruction |
|--------------|-------------|
| x86-64 | `syscall` |
| x86 (32-bit) | `int $0x80` |
| ARM64 | `svc #0` |
| ARM (32-bit) | `svc #0` or `swi #0` |

---

## Notes

> [!IMPORTANT]
> - Syscall numbers are **NOT** portable across architectures
> - On x86-64, `%r10` is used for the 4th argument (not `%rcx` as in regular function calls)
> - On ARM architectures, the syscall number is in a separate register (`r7`/`x8`), not the first argument register
> - Return values are always in the first argument register (`%rax`, `%eax`, `x0`, `r0`)
> - Negative return values typically indicate errors (errno values)

> [!TIP]
> For complete syscall tables, refer to:
> - x86-64: `/usr/include/asm/unistd_64.h`
> - x86: `/usr/include/asm/unistd_32.h`
> - ARM64: `/usr/include/asm-generic/unistd.h`
> - ARM: `/usr/include/arm-linux-gnueabihf/asm/unistd.h`
