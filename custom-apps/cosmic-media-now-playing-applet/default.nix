# Prebuilt .deb from upstream releases (no Rust compile). Bumped by `pkg-update` (runs before niup).
{ pkgs, lib, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "cosmic-media-now-playing-applet";
  version = "0.26.0";

  src = pkgs.fetchurl {
    url = "https://github.com/stldave314/cosmic-media-now-playing-applet/releases/download/v${version}/${pname}_${version}-1_amd64.deb";
    hash = "sha256-WE3cwKp3ohh6sq3JRMSWqLAeq7YoiyIano/A6HJYZm4=";
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
    description = "Now-playing media applet for the COSMIC Desktop Environment";
    homepage = "https://github.com/stldave314/cosmic-media-now-playing-applet";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-media-now-playing-applet";
    platforms = [ "x86_64-linux" ];
  };
}
