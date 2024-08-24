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
          openWatcom_1_9 = pkgs.fetchurl {
            url = "https://github.com/open-watcom/open-watcom-1.9/releases/download/ow1.9/open-watcom-c-dos-1.9.exe";
            hash = "sha256-pIXumz0FlCxMSqn2hrB0zq9nZmXt29b6k/1ATO0Axoc=";
          };
          # https://www.vogons.org/viewtopic.php?t=68139
          cdromDrivers = pkgs.fetchurl {
            url = "https://www.vogons.org/download/file.php?id=65849";
            hash = "sha256-fWwuHlWvf7keM2dFdp7q2pEq6u8bkC2OJPasujBJWrA=";
          };
          mouseDrivers = pkgs.fetchzip {
            url = "http://cutemouse.sourceforge.net/download/cutemouse21b4.zip";
            hash = "sha256-gUKk08fud6rMuteVoHRRjT5rBWeJbWE9nRQLqeZRaRQ=";
            stripRoot = false;
          };
          monkeyIsland = pkgs.fetchtorrent {
            url = "https://archive.org/download/monkey_dos/monkey_dos_archive.torrent";
            hash = "sha256-nzMO09OHA2VQJULlTE2g3e88DQfe/23MrbDdGD+3kG0=";
          };
          monkeyisland2 = pkgs.fetchtorrent {
            url = "https://archive.org/download/msdos_Monkey_Island_2_-_LeChucks_Revenge_1991/msdos_Monkey_Island_2_-_LeChucks_Revenge_1991_archive.torrent";
            hash = "sha256-6Gxicbh/X/wTBzkOGX3smvX1jFQmY9zr5wH8ElSGcQw=";
          };
          doom2 = pkgs.fetchtorrent {
            url = "https://archive.org/download/Doom-2/Doom-2_archive.torrent";
            hash = "sha256-+Erxmc5AlWRp6obm8WFyEry3N4F0PwjOjnnb13Om9aI=";
          };
          pcpaint = pkgs.fetchtorrent {
            url = "https://archive.org/download/pcpaint31portableversion/pcpaint31portableversion_archive.torrent";
            hash = "sha256-uBtECw7eezkdGOvPB3I06UfmKD+avkXGDWCIg5SmtAY=";
          };
          rolandRoms = pkgs.stdenv.mkDerivation {
            name = "mt-32-roland-roms";
            src = pkgs.fetchtorrent {
              url = "https://archive.org/download/mame-versioned-roland-mt-32-and-cm-32l-rom-files/mame-versioned-roland-mt-32-and-cm-32l-rom-files_archive.torrent";
              hash = "sha256-cJ8DDcRFNIO3FYqM8+yHdMpxWMbf29U0gS/rHoKxHcQ=";
            };
            nativeBuildInputs = [ pkgs.unzip ];

            phases = [
              "unpackPhase"
              "installPhase"
            ];

            installPhase = ''
              mkdir -p $out
              unzip -d $TMPDIR $src/mame-versioned-mt-32-and-cm-32l-rom-files.zip
              cp "$TMPDIR/mt32_pcm.rom" $out/MT32_PCM.ROM
              cp "$TMPDIR/mt32_ctrl_2_07.rom" $out/MT32_CONTROL.ROM
            '';
          };
          dosBench = pkgs.fetchurl {
            url = "https://www.philscomputerlab.com/uploads/3/7/2/3/37231621/dosbench_v1.6.zip";
            hash = "sha256-TZk1YBHUIMnzfz8vcn4sgg+jqjh4uG/cxl2wlpn1R6Y=";
          };
          dosboxConf = pkgs.writeText "dosbox-x.conf" ''
            [render]
            scaler=normal2x forced

            [dosbox]
            machine=svga_s3
            fastbioslogo=true
            startbanner=false
            memsize=16

            [cpu]
            core=normal
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
          toolsIso = pkgs.stdenvNoCC.mkDerivation {
            pname = "zptools-iso";
            version = "1.0";
            phases = [ "installPhase" ];
            nativeBuildInputs = [
              pkgs.cdrkit
              pkgs.unzip
            ];
            installPhase = ''
              runHook preInstall
              mkdir -p $out
              TMPDIR=$(mktemp -d)
              cp -r ${openWatcom_1_9} $TMPDIR/WATCOM.EXE
              cp ${mouseDrivers}/bin/ctmouse.exe $TMPDIR/CTMOUSE.EXE
              unzip ${monkeyIsland}/MONKEY.zip -d $TMPDIR/MONKEY
              unzip ${doom2}/Doom2.zip -d $TMPDIR/DOOM2
              unzip ${pcpaint}/PCPaint31-Installed.zip -d $TMPDIR/PCPAINT
              unzip "${monkeyisland2}/Monkey_Island_2_-_LeChucks_Revenge_1991.zip" -d $TMPDIR
              mv "$TMPDIR/mi2" $TMPDIR/MONKEY2
              unzip ${dosBench} -d $TMPDIR/DOSBENCH
              mkisofs -J -l -R -V "ZPDosTools" -iso-level 4 -o $out/tools.iso $TMPDIR
              runHook postInstall
            '';
          };
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
            EOF
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
            EOF
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
              -c "IMGMOUNT D ${toolsIso}/tools.iso -t cdrom" \
              -c "BOOT C:"
            EOF
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

        };

    };
}
