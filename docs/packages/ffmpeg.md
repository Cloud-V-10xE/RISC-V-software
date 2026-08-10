# FFmpeg

FFmpeg is the de-facto standard toolkit for decoding, encoding, transcoding and streaming audio and video.

## Why prebuilt for RISC-V?

**No prebuilt riscv64 FFmpeg exists anywhere.** All three canonical static-build providers ship x86_64 and arm64 only: [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds), [John Van Sickle](https://johnvansickle.com/ffmpeg/), and eugeneware/ffmpeg-static.

The distro gap is unusually costly here. Ubuntu 24.04 riscv64 is frozen at FFmpeg 6.1.1 with no `noble-updates` entry, while upstream is on 9.x — and the difference is not just features. RISC-V vector assembly counts:

| Release | `libavcodec/riscv` asm files |
|---|---|
| n6.1 (Ubuntu 24.04) | 30 |
| n7.1 (Debian trixie) | 92 |
| n8.1 | 102 |

That work — largely by Rémi Denis-Courmont, with SiFive and RISE-funded H.264/HEVC/VVC kernels — shows 4x–20x checkasm speedups on Kendryte K230 and BananaPi F3 hardware. Building from source ships roughly **3.4x more RISC-V-optimized code** than the distro package.

## Portability

This build is deliberately generic — no `-march=rv64gcv`. FFmpeg gates every RVV routine behind `.option arch, +v` plus runtime hwprobe detection, so one binary runs fast on RVV-1.0 parts (K230, SpacemiT K1) *and* still works on T-Head XTheadVector boards (StarFive JH7110 / VisionFive 2, Allwinner D1), where a force-enabled `+v` build would crash with SIGILL.

## Licensing

Built with `--enable-gpl --enable-version3` and **without** `--enable-nonfree`, so the result is redistributable. AAC encoding uses FFmpeg's native encoder rather than the non-redistributable fdk-aac.

## License

GPL-3.0-or-later (as configured) — https://ffmpeg.org/legal.html
