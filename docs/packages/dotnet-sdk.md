# .NET SDK

The .NET SDK includes everything needed to build, run, and publish .NET applications — compiler, runtime, NuGet package manager, and CLI tools.

## Why prebuilt for RISC-V?

Microsoft does not publish official .NET binaries for riscv64. Building .NET from source requires a multi-step process involving the runtime, aspnetcore, and installer repositories, taking several hours on capable hardware. This prebuilt binary enables C# and F# development on RISC-V without that complexity.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/dotnet-sdk-<version>-riscv64-linux.tar.gz
mkdir -p $HOME/.dotnet
tar -xzf dotnet-sdk-<version>-riscv64-linux.tar.gz -C $HOME/.dotnet
export PATH=$HOME/.dotnet:$PATH
export DOTNET_ROOT=$HOME/.dotnet
```

## Usage

```bash
dotnet --version
dotnet new console -n MyApp
dotnet run
```

## License

MIT — https://github.com/dotnet/sdk/blob/main/LICENSE.txt
