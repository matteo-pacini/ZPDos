{
  stdenvNoCC,
  lib,
  fetchtorrent,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "mt-32-roland-roms";
  version = "1988";

  src = fetchtorrent {
    url = "https://archive.org/download/mame-versioned-roland-mt-32-and-cm-32l-rom-files/mame-versioned-roland-mt-32-and-cm-32l-rom-files_archive.torrent";
    hash = "sha256-cJ8DDcRFNIO3FYqM8+yHdMpxWMbf29U0gS/rHoKxHcQ=";
  };
  nativeBuildInputs = [ unzip ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out
    unzip -d $TMPDIR $src/mame-versioned-mt-32-and-cm-32l-rom-files.zip
    cp "$TMPDIR/mt32_pcm.rom" $out/MT32_PCM.ROM
    cp "$TMPDIR/mt32_ctrl_2_07.rom" $out/MT32_CONTROL.ROM
  '';

  meta = {
    platforms = lib.platforms.all;
  };
}
