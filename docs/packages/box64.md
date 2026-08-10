# box64

box64 runs x86-64 Linux binaries on non-x86 hardware via dynamic recompilation.

## Why prebuilt for RISC-V?

This is the most RISC-V-specific package in the archive — it is how RISC-V users run software that has no RISC-V build at all.

Upstream publishes **no host binary for any architecture**: the v0.4.x releases contain only bundles of x86 *libraries*, not box64 itself. Ubuntu 24.04 has no box64 package at all, and Debian trixie carries 0.3.4 against upstream 0.4.x.

That version gap matters more than usual, because PLCT Lab's RVV 1.0 work — translating 100+ SSE instructions to RISC-V vector instructions, reported at roughly **300% faster than the scalar path** — landed in the 0.4 series. box64 also makes use of Zba/Zbb/Zbc/Zbs and the XTheadBa/Bb/MemIdx/CondMov extensions.

## Note

RISC-V uses **Box32** (bundled here) for 32-bit x86 support, not the separate box86 project.

## License

MIT — https://github.com/ptitSeb/box64/blob/main/LICENSE
