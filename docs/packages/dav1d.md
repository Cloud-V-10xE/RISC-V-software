# dav1d

dav1d is VideoLAN's AV1 decoder, focused on speed and correctness.

## Why prebuilt for RISC-V?

dav1d ships **source only, for every architecture** — there are no upstream binaries to fall back on.

The riscv64 win is not just freshness. Ubuntu 24.04 carries dav1d 1.4.1, whose `src/riscv/64/` contains exactly **one** assembly file (`itx.S`, inverse transforms). Upstream 1.5.x adds `cdef`, `ipred`, `mc`, `mc16`, `pal` and `filmgrain` RVV assembly — including the motion-compensation path that dominates AV1 decode time.

## Portability

Built generically; dav1d gates its RVV assembly behind runtime detection, so the binary is safe on non-vector RISC-V boards.

## License

BSD-2-Clause — https://code.videolan.org/videolan/dav1d/-/blob/master/COPYING
