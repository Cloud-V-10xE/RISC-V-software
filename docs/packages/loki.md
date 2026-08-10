# Loki

Grafana Loki is a horizontally scalable log aggregation system, designed to be cost-effective by indexing labels rather than full log text. It is the log half of the Prometheus/Grafana observability stack.

## Why prebuilt for RISC-V?

This is an unusual case: **Loki already builds cleanly for riscv64 upstream — the binary just never gets published.**

- `crosscompile.mk` lists `linux/riscv64` in `CROSS_BUILD_PLATFORMS`
- [PR #21597](https://github.com/grafana/loki/pull/21597) — *"feat(ci): Include linux/riscv64 Loki build in releases"* — was merged in April 2026 after the maintainers discussed and agreed
- The riscv64 build step passes in their release CI

Despite that, every recent Loki release carries 47 assets and **none of them is riscv64**.

There is no distro fallback either. Be careful when searching: the package named `loki` in Debian is version 2.4.7.4 and is **unrelated MCMC linkage-analysis software**, not Grafana Loki (which is at v3.x).

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-software/releases/latest/download/loki-<version>-riscv64-linux.tar.gz
tar -xzf loki-<version>-riscv64-linux.tar.gz -C /usr/local/
loki -version
```

## What's included

| Binary | Purpose |
|---|---|
| `loki` | The log aggregation server |
| `logcli` | Command-line client for querying Loki |
| `loki-canary` | Log-delivery verification agent |
| `promtail` | Log shipping agent (present only while upstream still ships it — being superseded by Grafana Alloy) |

All binaries are built with `CGO_ENABLED=0`, so they are static and portable across riscv64 distributions.

## Running

```bash
loki -config.file=/etc/loki/config.yaml
```

See the [upstream configuration reference](https://grafana.com/docs/loki/latest/configure/) for the config file format.

## License

AGPL-3.0 — https://github.com/grafana/loki/blob/main/LICENSE
