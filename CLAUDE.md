# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ZPDos is a Nix Flakes-based project that creates a fully-featured MS-DOS 6.22 environment running on an emulated 486DX2 machine using 86Box. It bundles programming tools (Turbo Pascal 7.0, Open Watcom, BWBasic), retro games (Doom II, Monkey Island, Prince of Persia), and development manuals.

## Build Commands

```bash
# Run the main 486DX2 emulator
nix run .#486dx2

# Build a specific package
nix build .#msdos
nix build .#turbo-pascal
nix build .#bwbasic
nix build .#tools
nix build .#manuals
nix build .#cdrom-drivers
nix build .#mouse-drivers

# Show available outputs
nix flake show

# Update flake dependencies
nix flake update
```

## Architecture

### Build System
- **Nix Flakes** orchestrates all builds with pinned dependencies in `flake.lock`
- Supports 4 platforms: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`, `x86_64-darwin`
- macOS (Darwin) has special path handling in the 486dx2 app wrapper

### Package Definitions (`pkgs/`)
| File | Purpose |
|------|---------|
| `msdos.nix` | MS-DOS 6.22 disk images from Archive.org torrent |
| `turbo-pascal.nix` | Turbo Pascal 7.0 from Archive.org torrent |
| `bwbasic.nix` | BWBasic cross-compiled with DJGPP toolchain |
| `tools.nix` | Creates ISO with games, apps, Open Watcom, multimedia |
| `manuals.nix` | PDF documentation collection |
| `cdrom-drivers.nix` | APICD driver floppy image |
| `mouse-drivers.nix` | CuteMouse driver floppy image |

### 86Box Configuration (`86Box/`)
- `86box.cfg`: Hardware config (486DX2 @ 66MHz, 16MB RAM, S3 ViRGE, SB16)
- `hdd.img.xz`: Compressed hard drive image (decompressed at runtime)

### Custom Tools (`ctools/`)
- `measure.c`: Program execution timer, compiles to DOS via Watcom

## Key Technical Details

### Cross-Compilation
BWBasic uses DJGPP with specific flags:
- Toolchain: `i586-pc-msdosdjgpp-gcc`
- Optimization: `-O2 -march=i486 -mtune=i486`
- DPMI: CWSDPMI for protected-mode support

### Package Sourcing
Resources come from multiple sources with SHA256 verification:
- Archive.org torrents (MS-DOS, games) via `fetchtorrent`
- Wayback Machine archives (drivers, tools)
- GitHub/SourceForge snapshots

### Build Pipeline
`flake.nix` builds all packages, then creates the `486dx2` app which:
1. Sets up symlinks to disk images and ISO files
2. Decompresses HDD image from XZ
3. Links 86box.cfg configuration
4. Launches 86Box
5. Cleans up on exit

## Adding New Content

### New Tools/Games
1. Add fetch definition in `pkgs/tools.nix` with sha256 hash
2. Update ISO creation command (`mkisofs`)
3. Document the source URL

### New Packages
1. Create `.nix` file in `pkgs/`
2. Follow nixpkgs conventions (mkDerivation phases)
3. Add to `flake.nix` outputs
4. Test with `nix build .#<package-name>`

## Troubleshooting

- **Hash mismatches**: Source URLs may have moved; check Wayback Machine
- **Build failures**: Use `nix repl` to debug flake evaluations
- **Platform issues**: Darwin paths differ from Linux; check wrapper script in `flake.nix`
