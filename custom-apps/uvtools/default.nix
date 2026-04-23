{ pkgs, ... }:

let
  version = "6.0.1";

  src = pkgs.fetchzip {
    url =
      "https://github.com/sn4k3/UVtools/releases/download/v${version}/UVtools_linux-x64_v${version}.zip";
    hash = "sha256-BfYEhFAeWup0yDeb41hKiq7MEJCwp9iUnXJjq+Aogl8=";
    stripRoot = false;
  };
in pkgs.stdenv.mkDerivation {
  pname = "uvtools";
  inherit version src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = with pkgs; [
    icu
    zlib
    openssl
    libgdiplus
    libglvnd
    libx11
    libice
    libsm
    libxi
    libxcursor
    libxrandr
    fontconfig
    lttng-ust
  ];

  autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/uvtools
    cp -r * $out/share/uvtools/

    mkdir -p $out/bin

    # --- UPDATED LIBRARIES ---
    # Added libXinerama (multi-monitor support) and libXft (font scaling)
    makeWrapper $out/share/uvtools/UVtools $out/bin/uvtools \
      --prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath [
          pkgs.libglvnd
          pkgs.libx11
          pkgs.libice
          pkgs.libsm
          pkgs.icu
          pkgs.openssl
          pkgs.zlib
          pkgs.libgdiplus
          pkgs.fontconfig
          pkgs.libxinerama
          pkgs.libxft
        ]
      }

    if [ -f $out/share/uvtools/icon.png ]; then
      install -D $out/share/uvtools/icon.png $out/share/icons/hicolor/512x512/apps/uvtools.png
    fi

    runHook postInstall
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "uvtools";
      desktopName = "UVTools";
      exec = "uvtools %f";
      icon = "uvtools";
      comment =
        "MSLA/DLP, File analysis, calibration, repair, conversion and manipulation";
      categories = [ "Graphics" "Engineering" ];
      mimeTypes = [ "application/x-cxdlpv4" ];
    })
  ];
}
