# Ruby

Ruby is a dynamic, object-oriented programming language designed for developer happiness. Powers Rails, Jekyll, and many other frameworks.

## Why prebuilt for RISC-V?

`apt install ruby` on Ubuntu Noble gives Ruby 3.2. Ruby 3.3 and 3.4 bring YJIT improvements (30-40% faster Rails apps), better memory management, and new language features. No prebuilt riscv64 binary exists for these versions.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/ruby-<version>-riscv64-linux.tar.gz
sudo tar -xzf ruby-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Note on Gems

This build ships without bundled gems (minitest, rake) due to network restrictions during the build. Install them manually:

```bash
gem install minitest rake bundler
```

## License

Ruby License / BSD-2-Clause — https://www.ruby-lang.org/en/about/license.txt
