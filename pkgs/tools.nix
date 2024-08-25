{
  stdenvNoCC,
  lib,
  fetchurl,
  fetchtorrent,
  fetchzip,
  cdrkit,
  unzip,
  p7zip,
}:
let
  openWatcom_1_9 = fetchurl {
    url = "https://github.com/open-watcom/open-watcom-1.9/releases/download/ow1.9/open-watcom-c-dos-1.9.exe";
    hash = "sha256-pIXumz0FlCxMSqn2hrB0zq9nZmXt29b6k/1ATO0Axoc=";
  };
  mouseDrivers = fetchzip {
    url = "http://cutemouse.sourceforge.net/download/cutemouse21b4.zip";
    hash = "sha256-gUKk08fud6rMuteVoHRRjT5rBWeJbWE9nRQLqeZRaRQ=";
    stripRoot = false;
  };
  monkeyIsland = fetchtorrent {
    url = "https://archive.org/download/monkey_dos/monkey_dos_archive.torrent";
    hash = "sha256-nzMO09OHA2VQJULlTE2g3e88DQfe/23MrbDdGD+3kG0=";
  };
  doom2 = fetchtorrent {
    url = "https://archive.org/download/Doom-2/Doom-2_archive.torrent";
    hash = "sha256-+Erxmc5AlWRp6obm8WFyEry3N4F0PwjOjnnb13Om9aI=";
  };
  pcpaint = fetchtorrent {
    url = "https://archive.org/download/pcpaint31portableversion/pcpaint31portableversion_archive.torrent";
    hash = "sha256-uBtECw7eezkdGOvPB3I06UfmKD+avkXGDWCIg5SmtAY=";
  };
  dosBench = fetchurl {
    url = "https://www.philscomputerlab.com/uploads/3/7/2/3/37231621/dosbench_v1.6.zip";
    hash = "sha256-TZk1YBHUIMnzfz8vcn4sgg+jqjh4uG/cxl2wlpn1R6Y=";
  };
  mpxPlay = fetchurl {
    url = "https://altushost-swe.dl.sourceforge.net/project/mpxplay/Mpxplay/Mpxplay%20v1.67/MPXP167G.ZIP?viasf=1";
    hash = "sha256-rZCmxfzCIKFH+vahl+XdWwCkgvEEWRa4lzaPHkBS5dw=";
  };
  mxPlayExtender = fetchurl {
    url = "https://mpxplay.sourceforge.net/DOS4G261.ZIP";
    hash = "sha256-RuDgtYYsmzIFYDQ4zSYp/iZDWK9uJaVP9umwyrR5ra0=";
  };
  eldenRingMp3 = fetchurl {
    url = "https://archive.org/download/shoi-miyazawa-yuka-kitamura-yoshimi-kudo-tai-tomisawa-elden-ring-original-game-soundtrack/1-01%20Elden%20Ring.mp3";
    hash = "sha256-fAu7ZOBixSxJKEiQ4nYqF3sCa3n+Yxg5/p9YVMbG/yY=";
  };
  ags = fetchurl {
    url = "http://www.doshaven.eu/wp-content/uploads/2018/01/ags_231.zip";
    hash = "sha256-8kO7wyn/pAOVYsb/4cXkvr/1jJkkeKXpf759u+MJ6aI=";
  };
  princeOfPersia = fetchurl {
    url = "https://www.popuw.com/files/disks/PoP_v1.3_3.5_Disk.zip";
    hash = "sha256-2tx3WSCfM3FEnKejesocmLLpd+ogOR1NyV02iws4GOs=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "zpdos-tools";
  version = "1.0";

  nativeBuildInputs = [
    cdrkit
    unzip
    p7zip
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    TMPDIR=$(mktemp -d)

    cp -r ${openWatcom_1_9} $TMPDIR/WATCOM.EXE

    cp ${mouseDrivers}/bin/ctmouse.exe $TMPDIR/CTMOUSE.EXE
    unzip ${monkeyIsland}/MONKEY.zip -d $TMPDIR/MONKEY
    unzip ${doom2}/Doom2.zip -d $TMPDIR/DOOM2
    unzip ${pcpaint}/PCPaint31-Installed.zip -d $TMPDIR/PCPAINT
    unzip ${dosBench} -d $TMPDIR/DOSBENCH

    unzip ${mpxPlay} -d $TMPDIR/MPXPLAY
    mv "$TMPDIR/MPXPLAY/mpxplay.exe" $TMPDIR/MPXPLAY/MPXPLAY.EXE
    unzip ${mxPlayExtender} -d $TMPDIR/MPXPLAY
    cp ${eldenRingMp3} $TMPDIR/MPXPLAY/ELDENRING.MP3

    unzip ${ags} -d $TMPDIR/AGS    

    unzip ${princeOfPersia} -d $TMPDIR/POP

    mkisofs -J -R -V "ZPDosTools" -iso-level 1 -input-charset "cp437" -o $out/tools.iso $TMPDIR
    runHook postInstall
  '';

  meta = {
    platforms = lib.platforms.all;
  };

}
