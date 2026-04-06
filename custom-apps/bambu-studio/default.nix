{ pkgs ? import <nixpkgs> { } }:

let
  version = "02.05.02.51";
  pname = "bambu-studio";

  src = pkgs.fetchurl {
    url =
      "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubuntu-24.04_v${version}-20260327222803.AppImage";
    sha256 = "b5675af34337715e61ced12862465519a6d032083aa7273f3a788f25f8213744";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

in pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs:
    with pkgs; [
      openssl_3
      tzdata
      cacert

      gtk3
      gdk-pixbuf
      glib
      pango
      cairo

      webkitgtk_4_1
      glib-networking

      curl
      openssl
      nss
      nspr
      cacert

      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad

      udev
      dbus
      libxshmfence
      libglvnd
      mesa

      libX11
      libXext
      libXdamage
      libXfixes
      libXcomposite
      libXcursor
      libXrandr
      libXi

      # Utilities
      icu
      zlib
      expat
    ];

  profile = ''
    export GIO_EXTRA_MODULES="${pkgs.glib-networking}/lib/gio/modules"
    export WEBKIT_DISABLE_COMPOSITING_MODE=1

    # Force the MQTT plugin to find the standard Linux SSL certificates
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    export SSL_CERT_DIR="${pkgs.cacert}/etc/ssl/certs"
  '';

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/BambuStudio.desktop $out/share/applications/${pname}.desktop

    # Grab the icon from the extracted AppImage
    install -m 444 -D ${appimageContents}/BambuStudio.png $out/share/icons/hicolor/192x192/apps/${pname}.png || true

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}' \
      --replace 'Icon=BambuStudio' 'Icon=${pname}'
  '';
}
