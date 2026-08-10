# SVT-AV1

SVT-AV1 is the Scalable Video Technology AV1 encoder/decoder maintained under AOMedia.

## Why prebuilt for RISC-V?

Upstream publishes **no binaries at all** — the GitLab releases carry zero assets for every architecture. Ubuntu 24.04 ships SVT-AV1 1.7.0 while upstream is on 4.x: three major versions of encoder speed and quality work.

## Honest caveat

SVT-AV1 has **no RISC-V SIMD tier**. `Source/Lib` contains `ASM_AVX2`, `ASM_AVX512`, `ASM_NEON`, `ASM_SVE`, `ASM_SSE*` and `C_DEFAULT` — nothing for RISC-V — so riscv64 runs the portable C path. This package is a *version* win, not a vectorization win. (There is an active upstream proposal to adopt Google Highway for portable SIMD, which would change this.)

## License

BSD-3-Clause-Clear + AOM Patent License — https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/LICENSE.md
