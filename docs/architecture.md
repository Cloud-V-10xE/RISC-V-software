# Architecture

How a package gets from upstream source to a binary on the website.

## The shape of it

Every package build is a thin overlay on one reusable workflow. A
`build-<package>.yml` declares only what is specific to that package — its
schedule, its apt dependencies, and the shell that fetches and compiles it —
and hands the rest to `_build-package.yaml`, which owns the parts that are the
same everywhere:

```
build-gcc.yml ─┐
build-node.yml ─┼─→ _build-package.yaml ─→ artifact + release asset
build-ffmpeg.yml ┘        (runner, apt, checkout, checksum,
   … 23 more              provenance, publish, pages refresh)
```

The contract is small: a `build-script` must export `ASSET_NAME` and
`ASSET_PATH` to `$GITHUB_ENV`. Everything downstream keys off those two
variables, and a build that exits 0 without setting them fails loudly rather
than silently publishing nothing.

## Where builds run

Two fleets, selected by the `runner` input:

| Label | Hardware | Used by |
|---|---|---|
| `RISCV64` | self-hosted Milk-V Pioneer (SG2042) | every package build by default |
| `ubuntu-24.04-riscv` | RISE CI, Scaleway Elastic Metal RV1 | the RISE CI enablement workflows |

x86 jobs (`ubuntu-latest`) exist only where a package publishes multi-arch
container images and needs an amd64 half, plus for coordination work — version
resolution, manifest creation, the Pages build — which compiles nothing and
should not consume scarce RISC-V capacity.

The self-hosted fleet runs the container image built by `build-runner-image.yml`
(see `docs/packages/github-actions-riscv.md`), which is also how those builds
get Docker access.

## From build to website

1. **Build.** The build script resolves the upstream version, checks whether
   that exact asset is already published (`.github/scripts/skip-if-published.sh`)
   and stops early if so — an upstream project re-cutting the same version is
   not a reason to spend ten hours of the Pioneer on a byte-identical artifact.
2. **Record.** `.github/actions/build-environment` writes the OS, kernel, glibc
   and toolchain versions to the log and the run summary, because a consumer of
   a prebuilt binary cannot inspect the machine it came from.
3. **Verify and sign.** The asset is checksummed (`.sha256`, published beside
   it) and attested with `actions/attest-build-provenance`.
4. **Publish.** The asset is attached to a release tagged `release-YYYY-MM-DD`.
   This matters: the website is generated *purely from GitHub Releases*, so a
   build that only uploaded a workflow artifact would be invisible.
5. **Refresh.** A `repository_dispatch` triggers `update-pages.yml`, which
   regenerates the site.

`central-release.yml` runs monthly and collects the newest artifact per package
into one curated release. `update-pages.yml` additionally sweeps up any
successful build whose artifact never reached a release, so a binary has three
independent routes to the site rather than one.

## The website

`update-pages.yml` builds a static site from two inputs: `packages.json` for
metadata, and the GitHub Releases API for what actually exists. There is no
database and no build step beyond shell and `jq`.

Adding a package to the site means adding an entry to
`.github/pages/packages.json` — nothing else in the workflow needs touching.
Versions shown on the site are recovered from asset *filenames*, since every
release here is tagged by date and a date tells a visitor nothing about which
GCC they are getting.

## Repository layout

```
.github/
  workflows/_build-package.yaml   the base every package build extends
  workflows/build-*.yml           per-package overlays
  workflows/update-pages.yml      site generation + artifact backfill
  workflows/central-release.yml   monthly curated release
  actions/build-environment/      records host and toolchain per build
  scripts/skip-if-published.sh    stops a rebuild of an existing version
  pages/                          packages.json, CSS, JS, vendored icons
docs/packages/                    one page per package: why it exists, how to install
runner-image/                     the self-hosted runner container
github-runner-riscv/              vendored riscv64 fork of actions/runner
```

`github-runner-riscv/` is upstream C# carried here so the runner can be built
for riscv64; it is marked `linguist-vendored` so it does not misrepresent what
this repository is.
