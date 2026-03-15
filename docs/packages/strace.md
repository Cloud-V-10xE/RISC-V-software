# strace — System Call Tracer

strace intercepts and records system calls made by a process. Essential for debugging, performance analysis, and understanding application behavior at the OS level.

## Why prebuilt for RISC-V?

strace on RISC-V requires architecture-specific syscall tables and register decoding. Older versions lack complete RISC-V syscall support. The latest strace versions have full riscv64 syscall coverage including newer Linux kernel syscalls.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/strace-<version>-riscv64-linux.tar.gz
sudo tar -xzf strace-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
strace ls /tmp
strace -p <pid>
strace -e trace=network curl https://example.com
```

## License

LGPL-2.1 — https://github.com/strace/strace/blob/master/COPYING
