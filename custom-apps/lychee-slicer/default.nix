{ pkgs, ... }:

let
  version = "7.6.6";
  pname = "lychee-slicer";

  src = pkgs.fetchurl {
    url = "https://mango-lychee.nyc3.cdn.digitaloceanspaces.com/LycheeSlicer-${version}.AppImage";
    hash = "sha256-HVCAvukGeF4hRJ/l41iBV1MZD5i9qzIYGSgMrncNfDg=";
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
      icu
      zlib
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
    install -m 444 -D ${appimageContents}/lycheeslicer.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/lycheeslicer.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
  '';
}
