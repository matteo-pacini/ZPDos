{
  stdenvNoCC,
  fetchurl,
  unzip,
  mtools,
  dosfstools,
}:
stdenvNoCC.mkDerivation {
  pname = "zpdos-cdrom-drivers";
  version = "1.0";

  src = fetchurl {
    url = "https://web.archive.org/web/20240206023623/https://www.dosdays.co.uk/media/cdrom/apicd214.zip";
    hash = "sha256-0CNAIVpSNC3R7M1yQ4EzHkrvtEie5/vufXUWyy4I4g8=";
  };

  nativeBuildInputs = [
    unzip
    mtools
    dosfstools
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    unzip -d $TMPDIR $src
    mkfs.msdos -C $out/cdrom.img 1440
    mcopy -i $out/cdrom.img -s $TMPDIR/* ::

    runHook postInstall
  '';
}
