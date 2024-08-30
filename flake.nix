{
  description = "ZPDos Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          msdos = pkgs.callPackage ./pkgs/msdos.nix { };
          cdromDrivers = pkgs.callPackage ./pkgs/cdrom-drivers.nix { };
          mouseDrivers = pkgs.callPackage ./pkgs/mouse-drivers.nix { };
          manuals = pkgs.callPackage ./pkgs/manuals.nix { };
          turbo-pascal = pkgs.callPackage ./pkgs/turbo-pascal.nix { };
          bwbasic = pkgs.callPackage ./pkgs/bwbasic.nix { };
          tools = pkgs.callPackage ./pkgs/tools.nix { inherit turbo-pascal bwbasic; };
          _486dx2 = pkgs.writeScriptBin "486dx2" ''
            #!${pkgs.lib.getExe pkgs.bash}

            set -eo pipefail

            export PATH=${pkgs._86Box-with-roms}/bin:${pkgs.unzip}/bin:${pkgs.xz}/bin:$PATH

            # MS-DOS 6.22 symlink
            rm -f  msdos 2>/dev/null
            ln -s ${msdos} msdos

            # CD-ROM drivers symlink
            rm -f cdrom.img 2>/dev/null
            ln -s ${cdromDrivers}/cdrom.img cdrom.img

            # Mouse drivers symlink
            rm -f mouse.img 2>/dev/null
            ln -s ${mouseDrivers}/mouse.img mouse.img

            # Symlink tools image
            rm -f  tools.iso 2>/dev/null
            ln -s ${tools}/tools.iso tools.iso            

            # Symlink manuals
            rm -f  manuals 2>/dev/null
            ln -s ${manuals} manuals

            # Unpack the drive if not present
            if [[ ! -f hdd.img ]]; then
              xz -d "${./86Box/hdd.img.xz}" -c > hdd.img
            fi

            rm -f 86box.cfg 2>/dev/null
            ln -s "${./86Box/86box.cfg}" 86box.cfg

            if [[ $(uname) == "Darwin" ]]; then
              # Workaround for 
              # https://github.com/NixOS/nixpkgs/pull/335384#issuecomment-2294927503
              86Box "$PWD/86box.cfg" 
            else
              86Box
            fi

            # Cleanup
            rm -f msdos cdrom.img mouse.img tools.iso manuals 86box.cfg 2>/dev/null
          '';
        in
        {

          apps = {
            "486dx2" = {
              type = "app";
              program = "${pkgs.lib.getExe _486dx2}";
            };
          };

        };

    };
}
