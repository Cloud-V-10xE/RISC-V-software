# Nim

Nim is a statically typed compiled systems language that emits C.

## Why prebuilt for RISC-V?

Nim publishes no riscv64 binary through **any** channel:

- nim-lang.org release downloads: x86_64, x86, ARM64, ARMv7l only
- `nim-lang/nightlies`: no riscv64 asset
- `choosenim` (the standard installer): Linux **amd64 only**, so even a published tarball would not be installable the normal way

[nim-lang/nightlies#113](https://github.com/nim-lang/nightlies/issues/113) asks for exactly this and has sat unanswered.

Meanwhile the compiler needs **zero patches** — `compiler/installer.ini` already lists riscv64 and `csources_v2/build.sh` has a native riscv64 branch, so there is no bootstrap chicken-and-egg.

Ubuntu 24.04 riscv64 ships Nim **1.6.14**, a whole major version behind, and even Ubuntu 26.04 only reaches 2.2.4.

## License

MIT — https://github.com/nim-lang/Nim/blob/devel/copying.txt
