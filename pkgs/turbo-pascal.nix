{
  stdenvNoCC,
  fetchtorrent,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "turbo-pascal";
  version = "7.0";

  src = fetchtorrent {
    url = "https://archive.org/download/turbopascal7.0/turbopascal7.0_archive.torrent";
    hash = "sha256-le4QD7TGxxfWxv431tKSERU/fmLKZN//mzjGAAruuhI=";
  };

  nativeBuildInputs = [ unzip ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out

    unzip $src/TP70.zip -d $out

    runHook postInstall
  '';
}
