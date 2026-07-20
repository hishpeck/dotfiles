{ pkgs ? import <nixpkgs> { }, }:

let
  version = "02.07.01.62";
  pname = "bambu-studio";

  src = pkgs.fetchurl {
    url =
      "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubuntu24.04-v${version}-20260616195227.AppImage";
    sha256 = "4c415078dd96cb72258730cceb5c36f7d0aeb2f24b629122169427748bc56c3c";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

  unwrapped = pkgs.appimageTools.wrapType2 {
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
  };

in pkgs.symlinkJoin {
  name = pname;
  paths = [ unwrapped ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    mv $out/bin/${pname} $out/bin/${pname}-unwrapped
    ln -s ${
      pkgs.writeShellScript pname ''
        # Workaround for BambuStudio single-instance D-Bus case mismatch bug:
        # The second invocation sends to com.bambulab... (lowercase) but the running
        # instance registers as com.BambuLab... (camelCase). We detect the running
        # instance via D-Bus and send directly to the correct name.
        DBUS_NAME=$(${pkgs.dbus}/bin/dbus-send --session \
          --dest=org.freedesktop.DBus --type=method_call --print-reply \
          /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null \
          | grep -o 'com.BambuLab.BambuStudio.InstanceCheck.Object[0-9]*')

        if [ -n "$DBUS_NAME" ] && [ $# -gt 0 ]; then
          HASH=$(echo "$DBUS_NAME" | grep -o '[0-9]*$')
          MSG="${unwrapped}/bin/${pname}"
          for f in "$@"; do
            MSG="$MSG;\"$f\""
          done
          exec ${pkgs.dbus}/bin/dbus-send --session \
            --dest="com.BambuLab.BambuStudio.InstanceCheck.Object$HASH" \
            "/com/BambuLab/BambuStudio/InstanceCheck/Object$HASH" \
            "com.BambuLab.BambuStudio.InstanceCheck.Object$HASH.AnotherInstance" \
            "string:$MSG"
        else
          exec ${unwrapped}/bin/${pname} "$@"
        fi
      ''
    } $out/bin/${pname}
  '';
}
