{
  stdenvNoCC,
  fetchtorrent,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "msdos";
  version = "6.22";

  src = fetchtorrent {
    url = "https://archive.org/download/MS_DOS_6.22_MICROSOFT/MS_DOS_6.22_MICROSOFT_archive.torrent";
    hash = "sha256-B88pYYF9TzVscXqBwql2vSPyp2Yf2pxJ75ywFjUn1RY=";
  };

  nativeBuildInputs = [ unzip ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out

    unzip -d $TMPDIR "$src/MS DOS 6.22.zip"
    mv "$TMPDIR/MS DOS 6.22/Disk 1.img" $out/disk1.img
    mv "$TMPDIR/MS DOS 6.22/Disk 2.img" $out/disk2.img
    mv "$TMPDIR/MS DOS 6.22/Disk 3.img" $out/disk3.img

    runHook postInstall
  '';
}
