{ pkgs, ... }:

let
  version = "1.1.1";
  pname = "freecad";

  src = pkgs.fetchurl {
    url = "https://github.com/FreeCAD/FreeCAD/releases/download/${version}/FreeCAD_${version}-Linux-x86_64-py311.AppImage";
    hash = "sha256-4gBhOEALL6hfouFg6HLQB2frMpZOhQdYMPfhmKOoduE=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs =
    pkgs: with pkgs; [
      libxshmfence
      udev
      libglvnd
      libX11
      libxkbcommon
      icu
      zlib
      fontconfig
      freetype
      gtk3
      cairo
      gdk-pixbuf
      nss
      nspr
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cups
      dbus
      expat
      pango
      mesa
    ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/org.freecad.FreeCAD.desktop \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    for size in 16x16 32x32 48x48 64x64; do
      icon="${appimageContents}/usr/share/icons/hicolor/$size/apps/org.freecad.FreeCAD.png"
      if [ -f "$icon" ]; then
        install -m 444 -D "$icon" \
          "$out/share/icons/hicolor/$size/apps/org.freecad.FreeCAD.png"
      fi
    done
    install -m 444 -D ${appimageContents}/org.freecad.FreeCAD.svg \
      $out/share/icons/hicolor/scalable/apps/org.freecad.FreeCAD.svg
  '';
}
