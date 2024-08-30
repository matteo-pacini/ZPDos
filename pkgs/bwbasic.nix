{
  stdenvNoCC,
  dos2unix,
  fetchurl,
  fetchzip,
  unzip,
  djgpp,
}:
let
  dpmi = fetchzip {
    url = "https://www.delorie.com/pub/djgpp/current/v2misc/csdpmi7b.zip";
    hash = "sha256-1uW16JQYjbtAuHMPP6T+Y0U8KqNR3LtjDIaVxSc0GK8=";
    stripRoot = false;
  };
in
stdenvNoCC.mkDerivation {
  pname = "bwbasic";
  version = "3.20";

  src = fetchurl {
    url = "mirror://sourceforge/project/bwbasic/bwbasic/version%203.20/bwbasic-3.20.zip";
    hash = "sha256-7hju+rftka0a1QzKsz6wOMSr11NZXhmYKJCGfygjOfE=";
  };

  nativeBuildInputs = [
    dos2unix
    unzip
    djgpp
  ];

  unpackPhase = ''
    unzip $src
  '';

  postPatch = ''
    dos2unix configure
    patchShebangs configure
    chmod +x configure
  '';

  configurePhase = ''
    runHook preConfigure
    CFLAGS="-O2 -g0 -Wall -march=i486 -mtune=i486 -mfpmath=387 -fomit-frame-pointer -fno-strict-aliasing -fno-strict-overflow" \
    LDFLAGS="-s" \
    CC="i586-pc-msdosdjgpp-gcc" \
    CPP="i586-pc-msdosdjgpp-cpp" \
    AR="i586-pc-msdosdjgpp-ar" \
    RANLIB="i586-pc-msdosdjgpp-ranlib" \
    CXX="i586-pc-msdosdjgpp-g++" \
    CXXFLAGS="$CFLAGS" \
    DEFS="$CFLAGS" ./configure
    runHook postConfigure
  '';

  postBuild = ''
    i586-pc-msdosdjgpp-strip -s bwbasic.exe
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp bwbasic.exe $out/BWBASIC.EXE

    cp ${dpmi}/bin/CWSDPMI.exe $out

    runHook postInstall
  '';

}
