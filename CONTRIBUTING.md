# Contributing to RISC-V Software Archive

Thank you for your interest in contributing! This guide explains how to add a
new package, fix a failing build, or improve the documentation.

---

## Table of Contents

- [Adding a New Package](#adding-a-new-package)
- [Fixing a Failing Build](#fixing-a-failing-build)
- [Improving Documentation](#improving-documentation)
- [Build Workflow Guidelines](#build-workflow-guidelines)
- [Common Pitfalls](#common-pitfalls)

---

## Adding a New Package

Adding a new package requires three files and one JSON entry. Here is the
complete checklist:

### 1. Add an entry to `packages.json`

Edit `.github/pages/packages.json` and add your package to the appropriate
category. The order within a category determines the display order on the site.

```json
{
  "id": "mypackage",
  "label": "My Package",
  "category": "Build Tools",
  "description": "One sentence description — mention why riscv64 users need this",
  "central_release": true,
  "workflow": "build-mypackage.yml"
}
```

**Field reference:**

| Field | Description |
|-------|-------------|
| `id` | Must match the prefix of your asset filename. If your binary is `mypackage-1.2.3-riscv64-linux.tar.gz`, the id is `mypackage`. |
| `label` | Display name shown on the site. |
| `category` | One of: `Compilers & Toolchains`, `Runtimes`, `ML Frameworks`, `Build Tools`, `Infrastructure`. Add a new category name if none fit — it will appear automatically. |
| `description` | Keep it under 100 characters. |
| `central_release` | `true` for binary tarballs that go into the central release. `false` for Docker image workflows. |
| `workflow` | The filename of your build workflow. |

**Important:** Do not add a trailing comma after the last item in the array.
Invalid JSON silently breaks the entire site. Validate with `jq . .github/pages/packages.json` before committing.

### 2. Create the build workflow

Add `.github/workflows/build-mypackage.yml`. Use an existing workflow as a
template — `build-cmake.yml` or `build-ninja.yml` are the cleanest examples
for simple builds.

Key requirements for every workflow:

```yaml
# Correct trigger — no push trigger
on:
  workflow_dispatch:
  schedule:
    - cron: "0 0 X * *"   # pick a day not used by another workflow

jobs:
  build:
    runs-on: RISCV64
    steps:
      # Always clean workspace first on RISCV64
      - name: Clean workspace with elevated permissions
        run: |
          sudo rm -rf "$GITHUB_WORKSPACE"
          mkdir -p "$GITHUB_WORKSPACE"

      # Always upload artifact
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: mypackage-VERSION-riscv64-linux.tar.gz
          path: /path/to/tarball

      # Always trigger pages at the end
      - name: Trigger Pages update
        if: success()
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          event-type: update-pages
```

**Asset naming convention:** `<id>-<version>-riscv64-linux.tar.gz`

The `id` in the asset name must exactly match the `id` in `packages.json`.
The pages site matches assets to packages using `contains(id)` on the filename.

### 3. Add documentation

Add `docs/packages/mypackage.md` with at minimum:

- What the package is
- Why riscv64 users need a prebuilt binary
- Basic installation and usage instructions

### 4. Open a pull request

Open a PR with all four changes. The PR description should include:

- What the package is and why it's valuable for riscv64 users
- Expected build time on the Pioneer box
- Any known issues or limitations

---

## Fixing a Failing Build

1. Check the workflow run logs in the Actions tab
2. Identify which step failed and why
3. Common causes and fixes are documented in [docs/architecture.md](docs/architecture.md)
4. Fix the workflow file and open a PR

If the build fails because an upstream version changed (e.g. a new Go version
requires a newer bootstrap), update the relevant version pin in the workflow.

---

## Improving Documentation

Documentation files live in `docs/`. The site itself is generated from
`update-pages.yml` which reads `docs/packages/<id>/README.md` for each package.

To update a package's description on the site, edit the corresponding file in
`docs/packages/` and run the `Update GitHub Pages` workflow manually.

---

## Build Workflow Guidelines

These rules apply to all RISCV64 build workflows:

**Do:**
- Clean the workspace with `sudo rm -rf "$GITHUB_WORKSPACE"` as the first step
- Use `make -j$(nproc)` for parallel builds
- Quote all variable expansions: `"$GITHUB_WORKSPACE"` not `$GITHUB_WORKSPACE`
- Install `jq` explicitly if you use it — it is not installed by default
- Use `--depth=1` for git clones to save time and disk space
- Name tarballs `<id>-<version>-riscv64-linux.tar.gz`

**Don't:**
- Add a `push` trigger — it causes multi-hour builds to run on every commit
- Use `NodeSource` to install Node.js — it doesn't support riscv64; use `apt` instead
- Use `GOARCH=riscv64` on the RISCV64 runner — you're already on riscv64, it's redundant
- Use a container image from an x86 registry — it will fail to start on riscv64
- Use `--recurse-submodules` with `--depth=1` for projects with nested submodules — initialize them explicitly instead

---

## Common Pitfalls

| Problem | Cause | Fix |
|---------|-------|-----|
| `container is not running` | x86 Docker image on riscv64 host | Remove the `container:` block, run bare metal |
| `jq: command not found` | jq not installed by default | Add `jq` to `apt-get install` |
| `unsupported architecture riscv64` | NodeSource install script | Use `apt-get install nodejs` instead |
| `building X requires Go 1.2Y or later` | Bootstrap Go too old | Download newer Go bootstrap from `go.dev/dl` |
| `executable host ruby is required` | No Ruby installed for bootstrap | Add `ruby` to apt deps, use `--with-baseruby=$(which ruby)` |
| `contains("pkg")` returns 0 results on site | Asset filename doesn't match `id` | Rename asset to start with the `id` value |
| Site shows 0 releases for a package | Trailing comma in `packages.json` | Remove trailing comma, validate with `jq` |
| `absl::absl_check target not found` | System abseil too old | Use `-DABSL_PROVIDER=module` to use bundled abseil |
