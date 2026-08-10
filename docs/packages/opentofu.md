# OpenTofu

OpenTofu is the community fork of Terraform, governed by the Linux Foundation.

## Why prebuilt for RISC-V?

OpenTofu's releases ship linux 386/amd64/arm/arm64 and nothing else — 164 assets, no riscv64 — and it is packaged in **neither Debian nor Ubuntu** for any architecture.

## Why OpenTofu and not Terraform

Terraform also lacks riscv64, but it is **BUSL-licensed**, which makes redistributing prebuilt binaries legally fraught. OpenTofu is MPL-2.0 and safe to republish. The same reasoning applies if a secrets manager is ever wanted here: prefer OpenBao over Vault.

## License

MPL-2.0 — https://github.com/opentofu/opentofu/blob/main/LICENSE
