{
  stdenvNoCC,
  fetchzip,
  mtools,
  dosfstools,
}:
stdenvNoCC.mkDerivation {
  pname = "zpdos-mouse-drivers";
  version = "1.0";

  src = fetchzip {
    url = "https://web.archive.org/web/20221116175818/https://sta.c64.org/dosprg/cutemouse21b4.zip";
    hash = "sha256-gUKk08fud6rMuteVoHRRjT5rBWeJbWE9nRQLqeZRaRQ=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    mtools
    dosfstools
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mkfs.msdos -C $out/mouse.img 1440
    mcopy -i $out/mouse.img -s $src/* ::

    runHook postInstall
  '';
}
