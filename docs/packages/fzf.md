# fzf — Fuzzy Finder

fzf is a general-purpose command-line fuzzy finder. It integrates with shell history, file search, git log, and many other tools to provide interactive filtering.

## Why prebuilt for RISC-V?

fzf has no official riscv64 binary in its GitHub releases. It is one of the most popular developer productivity tools and a common dependency of shell configurations, Neovim plugins, and CI tooling. Building from source requires a working Go toolchain.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/fzf-<version>-riscv64-linux.tar.gz
sudo tar -xzf fzf-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
# Interactive file search
fzf

# Shell history search (add to .bashrc/.zshrc)
source /usr/local/bin/fzf --bash

# Pipe anything into fzf
git log --oneline | fzf
```

## License

MIT — https://github.com/junegunn/fzf/blob/master/LICENSE
