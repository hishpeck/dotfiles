{ stdenv, fetchurl, dpkg, makeWrapper, autoPatchelfHook, alsa-lib, atk
, at-spi2-atk, at-spi2-core, cairo, cups, dbus, expat, fontconfig, freetype
, gdk-pixbuf, glib, gtk3, libdrm, libnotify, libxcb, libxkbcommon, mesa, nss
, pango, systemd, ffmpeg, yt-dlp, libx11, libxscrnsaver, libxcomposite
, libxcursor, libxdamage, libxext, libxfixes, libxi, libxrandr, libxrender
, libxtst, libGL, bash, wrapGAppsHook3, asar, nodejs, deno
}: # <-- 1. Added deno here

stdenv.mkDerivation rec {
  pname = "patreon-dl-gui";
  version = "2.7.1";

  src = fetchurl {
    url =
      "https://github.com/patrickkfkan/patreon-dl-gui/releases/download/v${version}/${pname}_${version}_amd64.deb";
    hash = "sha256-LtzrahP6HwfgeJWUj5XXsPcpIo2Oi3VzQur7nyLfrqk=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
    wrapGAppsHook3
    asar
    nodejs
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libnotify
    libxcb
    libxkbcommon
    mesa
    nss
    pango
    systemd
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libGL
  ];

  dontWrapGApps = true;

  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R usr/* $out/

    rm -f $out/lib/patreon-dl-gui/chrome-sandbox
    rm -f $out/bin/patreon-dl-gui
    mkdir -p $out/bin

    if [ -f $out/share/applications/patreon-dl-gui.desktop ]; then
      substituteInPlace $out/share/applications/patreon-dl-gui.desktop \
        --replace "/opt/patreon-dl-gui/patreon-dl-gui" "$out/bin/patreon-dl-gui" \
        --replace "/usr/lib/patreon-dl-gui/patreon-dl-gui" "$out/bin/patreon-dl-gui" \
        --replace "Exec=patreon-dl-gui" "Exec=$out/bin/patreon-dl-gui" || true
    fi

    # --- THE NUCLEAR SHESCAPE FIX (NIXOS EDITION) ---
    asar extract $out/lib/patreon-dl-gui/resources/app.asar $out/lib/patreon-dl-gui/resources/app
    rm $out/lib/patreon-dl-gui/resources/app.asar

    cat << 'EOF' > patch.js
    const fs = require("fs");
    const file = process.argv[2];
    const bashPath = process.argv[3];
    let code = fs.readFileSync(file, "utf8");

    code = code.split('"sh"').join('"' + bashPath + '"');
    code = code.split("'sh'").join("'" + bashPath + "'");
    code = code.split('`sh`').join('`' + bashPath + '`');

    code = code.split('"/bin/sh"').join('"' + bashPath + '"');
    code = code.split("'/bin/sh'").join("'" + bashPath + "'");
    code = code.split('"/bin/bash"').join('"' + bashPath + '"');
    code = code.split("'/bin/bash'").join("'" + bashPath + "'");

    code = code.replace(/throw\s+new\s+[a-zA-Z0-9_$]+\([^)]*Shescape does not support[^)]*\)/gi, 'console.warn("Nuked Shescape error")');

    fs.writeFileSync(file, code);
    EOF

    node patch.js "$out/lib/patreon-dl-gui/resources/app/.vite/build/index.js" "${bash}/bin/bash"

    asar pack $out/lib/patreon-dl-gui/resources/app $out/lib/patreon-dl-gui/resources/app.asar
    rm -rf $out/lib/patreon-dl-gui/resources/app
    rm patch.js

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/lib/patreon-dl-gui/patreon-dl-gui $out/bin/patreon-dl-gui \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${ffmpeg}/bin:${yt-dlp}/bin:${deno}/bin \
      --prefix LD_LIBRARY_PATH : ${libGL}/lib \
      --set SHELL ${bash}/bin/bash \
      --add-flags "--no-sandbox"
  '';
}
