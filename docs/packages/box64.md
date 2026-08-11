# box64

box64 runs x86-64 Linux binaries on non-x86 hardware via dynamic recompilation.

## Why prebuilt for RISC-V?

This is the most RISC-V-specific package in the archive — it is how RISC-V users run software that has no RISC-V build at all.

Upstream publishes **no host binary for any architecture**: the v0.4.x releases contain only bundles of x86 *libraries*, not box64 itself. Ubuntu 24.04 has no box64 package at all, and Debian trixie carries 0.3.4 against upstream 0.4.x.

That version gap matters more than usual, because PLCT Lab's RVV 1.0 work — translating 100+ SSE instructions to RISC-V vector instructions, reported at roughly **300% faster than the scalar path** — landed in the 0.4 series. box64 also makes use of Zba/Zbb/Zbc/Zbs and the XTheadBa/Bb/MemIdx/CondMov extensions.

## Installation

```bash
sudo tar -xzf box64-<version>-riscv64-linux.tar.gz -C /usr/local/
box64 --version
```

### Transparent execution of x86-64 binaries

The tarball ships binfmt_misc rules at `/usr/local/lib/binfmt.d/`, which
`systemd-binfmt` reads alongside `/etc/binfmt.d/`. Activate them once:

```bash
sudo systemctl restart systemd-binfmt
```

x86-64 and i386 binaries then run by being executed directly, with no `box64`
prefix.

### Bundled x86 libraries

box64 ships a handful of x86_64 and i386 libraries for programs that want
something the host has no riscv64 equivalent of — old `libstdc++`, `libpng12`,
OpenSSL 1.x and similar. Upstream installs these to an absolute
`/usr/lib/box64-x86_64-linux-gnu`, which a relocatable `/usr/local` tarball
cannot own, so they live under the prefix instead:

```bash
export BOX64_LD_LIBRARY_PATH=/usr/local/share/box64/x64lib:/usr/local/share/box64/x86lib
```

Add that to your shell profile if you hit `library not found` running an x86
binary. Everything else works without it.

A reference copy of the system-wide config is at
`/usr/local/share/box64/box64.box64rc`. box64 reads the real one from
`/etc/box64.box64rc`, so copy it there if you want to customise it.

## Note

RISC-V uses **Box32** (bundled here) for 32-bit x86 support, not the separate box86 project.

## License

MIT — https://github.com/ptitSeb/box64/blob/main/LICENSE
