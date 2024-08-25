{
  description = "ZPDos Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
          msdos622Installer = pkgs.fetchtorrent {
            url = "https://archive.org/download/MS_DOS_6.22_MICROSOFT/MS_DOS_6.22_MICROSOFT_archive.torrent";
            hash = "sha256-B88pYYF9TzVscXqBwql2vSPyp2Yf2pxJ75ywFjUn1RY=";
          };
          # https://www.vogons.org/viewtopic.php?t=68139
          cdromDrivers = pkgs.fetchurl {
            url = "https://www.vogons.org/download/file.php?id=65849";
            hash = "sha256-fWwuHlWvf7keM2dFdp7q2pEq6u8bkC2OJPasujBJWrA=";
          };
          tools = pkgs.callPackage ./pkgs/tools.nix { };
          rolandRoms = pkgs.callPackage ./pkgs/roland-roms.nix { };
          dosboxConf = pkgs.writeText "dosbox-x.conf" ''
            [render]
            scaler=normal2x forced

            [dosbox]
            machine=svga_s3virge
            fastbioslogo=true
            startbanner=false
            memsize=16

            [video]
            vmemsize=4

            [cpu]
            core=normal
            fpu=true
            cycles=fixed 23880
            cputype=486

            [midi]
            mpu401 = intelligent
            mididevice = mt32
            mpubase = 330
            mpuirq = 9
            samplerate = 44100
            mt32.romdir=${rolandRoms}
            mt32.verbose=true
          '';
          installDos = pkgs.writeScriptBin "installDos" ''
            #!${pkgs.stdenv.shell}
            export PATH=${pkgs.dosbox-x}/bin:${pkgs.unzip}/bin:$PATH

            # Clean up any previous installation
            if [ -f hdd.img ]; then
              rm hdd.img 2>/dev/null
            fi

            # Unzip the MS-DOS 6.22 installer and rename the floppy images
            TMPDIR=$(mktemp -d)
            trap 'rm -rf $TMPDIR' EXIT
            unzip -d $TMPDIR "${msdos622Installer}/MS DOS 6.22.zip"
            mv "$TMPDIR/MS DOS 6.22/Disk 1.img" $TMPDIR/disk1.img
            mv "$TMPDIR/MS DOS 6.22/Disk 2.img" $TMPDIR/disk2.img
            mv "$TMPDIR/MS DOS 6.22/Disk 3.img" $TMPDIR/disk3.img

            # Create a blank hard disk image
            dosbox-x -nolog -silent -c "IMGMAKE ./hdd.img -t hd -size 1024 -fat 16"

            # Boot the installer
            dosbox-x -conf ${dosboxConf} \
              -c "IMGMOUNT C hdd.img" \
              -c "BOOT $TMPDIR/disk1.img $TMPDIR/disk2.img $TMPDIR/disk3.img"
          '';
          installCdromDrivers = pkgs.writeScriptBin "installCdromDrivers" ''
            #!${pkgs.stdenv.shell}
            export PATH=${pkgs.dosbox-x}/bin:${pkgs.unzip}/bin:$PATH

            if [ ! -f hdd.img ]; then
              echo "Error: hdd.img not found, run zpdos-install first" >&2
              exit 1
            fi

            # Unzip the CD-ROM drivers and rename the floppy image
            TMPDIR=$(mktemp -d)
            trap 'rm -rf $TMPDIR' EXIT
            unzip -d $TMPDIR ${cdromDrivers}
            mv $TMPDIR/cdrom_install_floppy_dos.ima $TMPDIR/cdrom.img

            # Boot the installer
            dosbox-x -conf ${dosboxConf} \
              -c "IMGMOUNT C hdd.img" \
              -c "IMGMOUNT A $TMPDIR/cdrom.img -t floppy" \
              -c "BOOT C:"
          '';
          runDos = pkgs.writeScriptBin "runDos" ''
            #!${pkgs.stdenv.shell}
            export PATH=${pkgs.dosbox-x}/bin:${pkgs.unzip}/bin:$PATH

            if [ ! -f hdd.img ]; then
              echo "Error: hdd.img not found, run zpdos-install first" >&2
              exit 1
            fi

            dosbox-x -conf ${dosboxConf} \
              -c "IMGMOUNT C hdd.img" \
              -c "IMGMOUNT D ${tools}/tools.iso -t cdrom" \
              -c "MOUNT G $PWD" \
              -c "BOOT C:"
          '';
        in
        {

          apps = {
            "zpdos-install" = {
              type = "app";
              program = "${pkgs.lib.getExe installDos}";
            };
            "zpdos-install-cdrom" = {
              type = "app";
              program = "${pkgs.lib.getExe installCdromDrivers}";
            };
            "zpdos-run" = {
              type = "app";
              program = "${pkgs.lib.getExe runDos}";
            };
          };

          packages = {
            zpdos-tools = tools;
          };

        };

    };
}
