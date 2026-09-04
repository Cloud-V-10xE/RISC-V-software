# Calico

Calico CNI for RISC-V, built from source in two parts: the pure-Go tooling
(`calicoctl`, the CNI plugin, `kube-controllers`, `typha`) and Felix, the node
dataplane agent, built separately because it needs a real C toolchain. Two
Docker Hub images (`calico-node`, `calico-cni`) are also published for
running Calico as a Kubernetes daemonset — see
[Container images](#container-images-calico-node--calico-cni) below.

## Why two packages

| Asset | Built by | What's in it |
|---|---|---|
| `calico-<version>-riscv64-linux.tar.gz` | `build-calico.yaml` | `calicoctl`, CNI plugin, `kube-controllers`, `typha` — pure Go, `CGO_ENABLED=0` |
| `calico-felix-<version>-riscv64-linux.tar.gz` | `build-calico-felix.yaml` | `calico-felix` — links a natively-compiled libbpf via CGO |

Felix's production build needs a compiled `libbpf.a` and CGO regardless of
which dataplane you end up running (see below), which is a heavier, more
failure-prone process than a plain `go build`. Keeping it a separate workflow
means a Felix build failing doesn't take the other four binaries down with it.

**Install both, from the same release.** `build-calico-felix.yaml` reads back
whatever Calico version `build-calico.yaml` already published and builds Felix
to match it exactly — it never independently resolves "latest Calico" itself.
Installing a Felix from a different version than the rest is the one
combination this packaging deliberately avoids; don't defeat that by manually
pairing binaries from different releases.

```bash
tar -xzf calico-<version>-riscv64-linux.tar.gz -C /usr/local/bin/
tar -xzf calico-felix-<version>-riscv64-linux.tar.gz -C /usr/local/bin/
```

## Upstream has no riscv64 support at all

Worth knowing before you rely on this: Project Calico does not support riscv64
in any official capacity. `calico/node`, `calico/cni`, `calico/kube-controllers`
and `calico/typha` ship `amd64`/`arm64`/`ppc64le`/`s390x` only — there is no
riscv64 manifest anywhere, and no CI job builds one. A maintainer confirmed why:
`calico/base`, the image every Calico component builds `FROM`, is built on
RHEL/UBI 8, and Red Hat has no riscv64 port. The tracking issue
([projectcalico/calico#9852](https://github.com/projectcalico/calico/issues/9852))
was closed `not_planned` after six months idle.

That blocker is specific to Calico's own *container image* pipeline. This
packaging never goes through it — it compiles the Go binaries directly from
source and packages its own tarballs — so it isn't affected. But it does mean
there is no upstream precedent to lean on: no other riscv64 build to
cross-check against, and no guarantee upstream changes won't break something
riscv64-specific that nobody upstream tests for.

## Felix, libbpf, and what "BPF-capable" actually means

Felix's own Makefile links a real, natively-compiled `libbpf` via CGO even for
architectures that will only ever run the default dataplane — that's not
specific to this build, it's how Calico builds Felix everywhere. This package
does the same: `calico-felix` here is BPF-*capable*, matching upstream's own
binaries, not a stripped-down build.

That does **not** mean the eBPF dataplane is enabled or required:

- `FelixConfiguration.bpfEnabled` defaults to `false`. Standard iptables/ipvs
  is the baseline Calico dataplane; eBPF is an explicit opt-in
  (`bpfEnabled: true` or `Installation.spec.calicoNetwork.linuxDataplane: BPF`).
- The iptables/ipvs path needs no BPF capability at all, at build or run time.
- If eBPF mode is ever enabled without kernel support, Felix logs "BPF
  dataplane mode enabled but not supported by the kernel. Disabling BPF mode."
  and falls back to iptables — it does not crash.

**What this build does not do**: compile Calico's eBPF C programs
(`felix/bpf-gpl/*.c`). That's a separate, additive Makefile target
(`build-bpf`), not a dependency of the `calico-felix` binary itself — the
userspace agent and the in-kernel BPF programs build independently. Those
`.o` files are only needed if you actually enable BPF mode, which this
packaging does not ship and has not built.

## Before enabling `bpfEnabled: true` on real hardware

This was **not verified** as part of building the package, and needs checking
directly on whatever machine will run it — not assumed from the fact that the
binary is BPF-capable:

```bash
uname -r
zcat /proc/config.gz 2>/dev/null | grep -E 'BPF_SYSCALL|BPF_JIT|DEBUG_INFO_BTF' \
  || grep -E 'BPF_SYSCALL|BPF_JIT|DEBUG_INFO_BTF' "/boot/config-$(uname -r)"
```

Context for why this needs a direct check rather than a general "riscv64 has
had eBPF since Linux 5.1" answer: Milk-V's own official Pioneer image is
Fedora 38 (kernel 6.1.31), not Debian. A "Debian trixie on Pioneer" system is
most likely RevyOS or a similar Sophgo-downstream-kernel build, not vanilla
Debian's own riscv64 kernel package — and which exact kernel and config a given
box is actually running was not something remote research could pin down.
Sophgo/RevyOS's own SG2042 kernel configs do set `CONFIG_BPF_JIT`,
`CONFIG_BPF_LSM`, `CONFIG_CGROUP_BPF`, and `CONFIG_DEBUG_INFO_BTF`, and both
imply `CONFIG_BPF_SYSCALL` is on — but "implied by dependency" is not the same
as confirmed on your specific box.

None of this affects the default, safe path: iptables mode needs nothing here
to be true, and is what this package runs unless you deliberately change it.

## Container images: `calico-node` / `calico-cni`

`build-calico-node.yaml` and `build-calico-cni.yaml` publish two multi-arch
(`amd64` + `riscv64`) Docker Hub images, built from the same `cmd/calico`
combined binary (CGO + the same libbpf link as the Felix package above) but
packaged very differently — matching how upstream itself splits these two
images, confirmed against the real deployed manifest
(`manifests/calico.yaml`), not assumed from the Dockerfiles alone:

| Image | Docker Hub | Matches upstream | Used as |
|---|---|---|---|
| `calico-node` | `cloudv10x/calico-node` | `quay.io/calico/node` (`node/Dockerfile`) | the main `calico-node` container |
| `calico-cni` | `cloudv10x/calico-cni` | `quay.io/calico/calico` (`docker/calico/Dockerfile`) | the `install-cni` and `upgrade-ipam` init containers |

These are genuinely different images, not one image under two names:
`calico-node` is runit-supervised and carries the iptables/nftables/conntrack
dataplane tooling; `calico-cni` is just the binary plus `calicoctl`/
`calico-ipam` symlinks, running unprivileged. Point a daemonset spec's
`calico-node` container at the first and its `install-cni`/`upgrade-ipam`
init containers at the second — they are not interchangeable.

Both are tagged `<calico-version>` and `latest`, each further suffixed
`-amd64`/`-riscv64` before being merged into a multi-arch manifest under the
plain tag — e.g. `cloudv10x/calico-node:3.30.3` resolves to the right
architecture automatically. Both workflows read the Calico version back from
`build-calico.yaml`'s own published release asset, the same guarantee
`build-calico-felix.yaml` already relies on, so neither image can drift to a
different Calico version than the tarball packages above.

### Scope decision: VXLAN only, no BIRD/BGP

`calico-node` ships **without** BIRD, bird6, or the confd service — it only
supports `CALICO_NETWORKING_BACKEND=vxlan` (or `none`). This was a deliberate
choice, not a limitation discovered too late:

- Traced from real source (`node/pkg/lifecycle/startup`,
  `node/pkg/health/health.go`, `node/filesystem/etc/rc.local`): BIRD is only
  ever invoked if the backend resolves to something other than
  `vxlan`/`none` — no code path here needs BIRD's presence in VXLAN mode, so
  omitting it is safe, not just untested.
- The image sets `CALICO_NETWORKING_BACKEND=vxlan` as its own Dockerfile
  default. If the calico-config ConfigMap's `calico_backend` key is ever
  left unset, this image fails safe (no BGP daemon it doesn't ship gets
  invoked) rather than crash-looping a missing-binary `bird` runit service.
- BIRD's own riscv64 buildability **was** separately verified — Calico's own
  fork (`github.com/projectcalico/bird`, the exact commit Calico's
  `metadata.mk` pins) cross-compiles cleanly to real, working riscv64 ELF
  binaries with zero source-level blockers (no inline asm, no
  architecture-specific code, real Debian/Alpine riscv64 precedent for the
  same codebase). It isn't shipped here because full-mesh BGP peering
  doesn't fit a spoke-only WireGuard topology without a route reflector at
  the hub, and VXLAN needs only the IP reachability such a topology already
  provides. If a future deployment needs BGP, that verification means adding
  it back is a known-buildable, bounded task, not open-ended research.

**Practical requirement**: whatever applies your Calico manifest/Installation
resource must set the networking backend to `vxlan` (the `calico_backend`
key in the `calico-config` ConfigMap, or the equivalent Installation-resource
field if you're using the Tigera operator instead of the plain manifest).
That's a manifest-level setting, separate from anything in these workflows.

## License

Apache-2.0 — https://github.com/projectcalico/calico/blob/master/LICENSE
