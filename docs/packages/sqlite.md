# SQLite — Embedded SQL Database

SQLite is the most widely deployed database engine in the world. It is a self-contained, serverless, zero-configuration SQL database library used by Android, iOS, Firefox, and countless other applications.

## Why prebuilt for RISC-V?

While SQLite is available in apt, the prebuilt binary here provides the latest version with all optional features enabled (FTS5, JSON, math functions). Useful for developers who need specific SQLite features or a consistent version across deployments.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/sqlite-<version>-riscv64-linux.tar.gz
sudo tar -xzf sqlite-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
sqlite3 --version
sqlite3 mydb.db
sqlite3 mydb.db "CREATE TABLE t (id INTEGER PRIMARY KEY, val TEXT);"
```

## Enabled Features

FTS5 (full-text search), readline support, JSON functions

## License

Public Domain — https://www.sqlite.org/copyright.html
