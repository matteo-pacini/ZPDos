# ZPDos

```
╔═══════════════════════════════════════════════════════════╗
║  ███████╗██████╗ ██████╗  ██████╗ ███████╗                ║
║  ╚══███╔╝██╔══██╗██╔══██╗██╔═══██╗██╔════╝                ║
║    ███╔╝ ██████╔╝██║  ██║██║   ██║███████╗                ║
║   ███╔╝  ██╔═══╝ ██║  ██║██║   ██║╚════██║                ║
║  ███████╗██║     ██████╔╝╚██████╔╝███████║                ║
║  ╚══════╝╚═╝     ╚═════╝  ╚═════╝ ╚══════╝                ║
║                                                           ║
║       MS-DOS 6.22 on a 486DX2 — One Command Away          ║
╚═══════════════════════════════════════════════════════════╝
```

A complete, reproducible MS-DOS 6.22 environment running on an emulated Intel 486DX2. Includes classic games, development tools, and programming manuals — all packaged with Nix for a single-command launch on Linux and macOS.

## Quick Start

```bash
nix run github:matteo-pacini/ZPDos#486dx2
```

Or clone and run locally:

```bash
git clone https://github.com/matteo-pacini/ZPDos.git
cd ZPDos
nix run .#486dx2
```

## Features

- **One command launch** — No manual setup, just `nix run`
- **Accurate hardware emulation** — 86Box provides cycle-accurate 486DX2 emulation
- **Cross-platform** — Works on Linux and macOS (x86_64 and ARM64)
- **Fully reproducible** — Nix Flakes ensure identical builds everywhere
- **Batteries included** — Games, compilers, and manuals ready to use

## Emulated Hardware

| Component | Specification |
|-----------|---------------|
| CPU | Intel 486DX2 @ 66MHz |
| RAM | 16 MB |
| Graphics | S3 ViRGE/DX (4MB VRAM) |
| Sound | Sound Blaster 16 + Roland MT-32 MIDI |
| Storage | IDE Hard Drive, 16x CD-ROM, 3.5" Floppy |
| Input | Serial Mouse |

## What's Inside

### Development Tools

| Tool | Description |
|------|-------------|
| **Turbo Pascal 7.0** | Complete IDE for Pascal development |
| **Open Watcom C 1.9** | Professional C/C++ compiler |
| **BWBasic 3.20** | Bywater BASIC interpreter |

### Games

| Game | Genre |
|------|-------|
| **Doom II** | First-person shooter |
| **Monkey Island** | Point-and-click adventure |
| **Prince of Persia** | Cinematic platformer |

### Utilities

- **PC Paint 3.1** — Painting and image editing
- **MPXPlay** — Audio player (MP3, OGG, FLAC)
- **DOSBench** — System benchmarking
- **DOSMID** — MIDI music player

### Documentation

Six programming manuals in PDF format:

- Turbo Pascal 7.0 User's Guide
- Turbo Vision 2.0 Programming Guide
- Open Watcom Programmer's Guide
- Open Watcom C Library Reference
- Advanced MS-DOS Programming (2nd Edition)
- The Art of Assembly Language (2nd Edition)

## Requirements

- **Nix package manager** with flakes enabled
- Approximately 500MB disk space

### Enabling Nix Flakes

Add to `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

## Building Individual Packages

```bash
nix build .#msdos          # MS-DOS 6.22 disk images
nix build .#turbo-pascal   # Turbo Pascal 7.0
nix build .#bwbasic        # BWBasic interpreter
nix build .#tools          # Tools ISO (games, utilities)
nix build .#manuals        # PDF documentation
nix build .#cdrom-drivers  # CD-ROM driver floppy
nix build .#mouse-drivers  # Mouse driver floppy
```

## Acknowledgments

- [86Box](https://86box.net/) — The x86 hardware emulator
- [Archive.org](https://archive.org/) — Software preservation
- [Nix](https://nixos.org/) — Reproducible builds
