# Prebuilt .deb from upstream releases (no Rust compile). Bumped by `pkg-update` (runs before niup).
{ pkgs, lib, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "cosmic-ext-whether";
  version = "0.7.0";

  src = pkgs.fetchurl {
    url = "https://github.com/nwxnw/cosmic-ext-whether/releases/download/v${version}/${pname}_${version}_amd64.deb";
    hash = "sha256-mzTng+2nRxHvGDgJMjonbBIQs7warKMt9pjsveQzT1Y=";
  };

  nativeBuildInputs = [ pkgs.dpkg pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.libxkbcommon pkgs.stdenv.cc.cc.lib ];
  # dlopen'd at runtime by libcosmic/winit, so autoPatchelf can't see them
  runtimeDependencies = [ pkgs.wayland pkgs.libGL pkgs.vulkan-loader pkgs.libxkbcommon ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall
    cp -r usr $out
    runHook postInstall
  '';

  meta = {
    description = "Weather applet for the COSMIC Desktop Environment";
    homepage = "https://github.com/nwxnw/cosmic-ext-whether";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-ext-whether";
    platforms = [ "x86_64-linux" ];
  };
}
