{ pkgs ? import <nixpkgs> { } }:

let
  version = "9.18.11";
  pname = "upnote";

  src = pkgs.fetchurl {
    url = "https://download.getupnote.com/app/UpNote.AppImage";
    sha256 = "sha256-0uVivYpe93zS1mkjf+znmFDbVpFXh2pTRu1xDqhmoJ0=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

in pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/upnote.desktop \
      $out/share/applications/${pname}.desktop

    for size in 16 32 48 64 128 256 512 1024; do
      icon="${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/upnote.png"
      if [ -f "$icon" ]; then
        install -m 444 -D "$icon" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png"
      fi
    done

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} --no-sandbox %U'
  '';
}
