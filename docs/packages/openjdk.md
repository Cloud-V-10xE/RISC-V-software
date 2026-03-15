# OpenJDK — Java Development Kit

OpenJDK is the open-source reference implementation of the Java Platform. Includes the JVM, compiler (`javac`), and standard library.

## Why prebuilt for RISC-V?

Java's official builds at jdk.java.net do not include riscv64 binaries. RISC-V support was added to OpenJDK but prebuilt binaries are not distributed officially. This build enables Java development and application deployment on RISC-V hardware without a multi-hour build from source.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/openjdk-<version>-riscv64-linux.tar.gz
sudo tar -xzf openjdk-<version>-riscv64-linux.tar.gz -C /usr/local/
export JAVA_HOME=/usr/local
export PATH=$JAVA_HOME/bin:$PATH
```

## Usage

```bash
java --version
javac --version
```

## License

GPL-2.0 with Classpath Exception — https://openjdk.org/legal/gplv2+ce.html
