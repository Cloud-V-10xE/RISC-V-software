# llama.cpp

llama.cpp runs LLM inference in plain C/C++ with no heavyweight framework dependency.

## Why prebuilt for RISC-V?

llama.cpp publishes release binaries for a long tail of platforms — **including s390x** — but not riscv64. The request to add it ([#20988](https://github.com/ggml-org/llama.cpp/issues/20988)) received a maintainer "sounds reasonable, feel free to open a PR" and was then closed `not_planned` by the stale bot.

Meanwhile the RVV engineering is active: VLEN=1024 `vec_dot`, xtheadvector support, and runtime feature detection via the `riscv_hwprobe` syscall in `ggml/src/ggml-cpu/arch/riscv/cpu-feats.cpp`. The build system already registers `rv64gc` and `rv64gc_v` variants. **Nothing needs patching — the binaries simply are not published.**

It is also absent from Debian trixie and from Ubuntu entirely.

## Runtime dispatch

Built with `GGML_CPU_ALL_VARIANTS=ON` and `GGML_BACKEND_DL=ON`, which compiles both the scalar and RVV backends as loadable modules and selects between them at runtime. One tarball stays correct on non-vector boards and upgrades itself to RVV where the hardware supports it.

## License

MIT — https://github.com/ggml-org/llama.cpp/blob/master/LICENSE
