{
  stdenvNoCC,
  lib,
  fetchurl,
}:
let
  tp70Manual = fetchurl {
    url = "https://archive.org/download/bitsavers_borlandturVersion7.0UsersGuide1992_7260603/Turbo_Pascal_Version_7.0_Users_Guide_1992.pdf";
    hash = "sha256-qaA0BBTuRhM/zSBZweWVBJy+z/5oaJ8sh+IW2mGbho8=";
  };
  tv2Manual = fetchurl {
    url = "https://archive.org/download/bitsavers_borlandTurrogrammingGuide1992_25707423/Turbo_Vision_Version_2.0_Programming_Guide_1992.pdf";
    hash = "sha256-YUpyVkdHs/aOt4SWJJxfqcDXWFioURUrTpM7VZ9lBlA=";
  };
  watcomProgrammerGuide = fetchurl {
    url = "https://openwatcom.org/ftp/manuals/1.5/pguide.pdf";
    hash = "sha256-7AcvJHQdqOmDKUpIHZZLJOZqi0w0bbwZm3yGfsjbH+w=";
  };
  watcomClibGuide = fetchurl {
    url = "https://openwatcom.org/ftp/manuals/1.5/clib.pdf";
    hash = "sha256-iXLSD3Fmn34uHldArVC+fr3kMfsM3ueYd5uPBDOiaXI=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "zpdos-manuals";
  version = "1.0";

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp ${tp70Manual} "$out/Turbo Pascal 7.0.pdf"
    cp ${tv2Manual} "$out/Turbo Vision 2.0.pdf"
    cp ${watcomProgrammerGuide} "$out/Open Watcom Programmer's Guide.pdf"
    cp ${watcomClibGuide} "$out/Open Watcom C Library Reference.pdf"
    runHook postInstall
  '';

  meta = {
    platforms = lib.platforms.all;
  };

}
