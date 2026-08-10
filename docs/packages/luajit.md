# LuaJIT

LuaJIT is a just-in-time compiler for Lua, used as the scripting engine in OpenResty, Neovim, and a large amount of game and networking middleware.

## Why prebuilt for RISC-V?

Upstream LuaJIT has **no RISC-V backend at all**. Its `src/` directory ships `lj_target_{arm,arm64,mips,ppc,x86}.h` and nothing for riscv — building stock LuaJIT on riscv64 fails outright with "No support for this architecture (yet)".

The riscv64 port has been open as [PR #1267](https://github.com/LuaJIT/LuaJIT/pull/1267) since September 2024, and [issue #628](https://github.com/LuaJIT/LuaJIT/issues/628) has been open since 2020. Neither has been merged.

There is also no apt path on the most common riscv64 base: **Ubuntu 24.04 LTS ships no riscv64 `luajit` package** (amd64, arm64, armhf and s390x only). Debian carries riscv64 support only via a ~330 KB downstream patch.

This build uses the [PLCT Lab LJRV patchset](https://github.com/plctlab/LuaJIT) (`riscv64-v2.1-branch`), the same lineage Debian patches in.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-software/releases/latest/download/luajit-<version>-riscv64-linux.tar.gz
tar -xzf luajit-<version>-riscv64-linux.tar.gz -C /usr/local/
luajit -v
```

## Verifying the JIT is active

The build asserts this in CI, but you can confirm on your own hardware:

```bash
luajit -e 'print(jit.status()); print(jit.arch)'
```

`jit.arch` must print `riscv64`. If it prints something else, or `jit` is nil, you have an interpreter-only build.

## Known limitations

LJRV describes itself as beta quality, and FFI struct passing is documented upstream as partially broken. Report issues you hit against [the LJRV repository](https://github.com/plctlab/LuaJIT).

## License

MIT — https://github.com/LuaJIT/LuaJIT/blob/v2.1/COPYRIGHT
