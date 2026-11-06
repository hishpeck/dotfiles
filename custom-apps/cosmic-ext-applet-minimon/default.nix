# Prebuilt .deb from upstream releases (no Rust compile). Bumped by `pkg-update` (runs before niup).
# nixpkgs lagged behind upstream (1.2.0 vs 1.3.0 as of 2026-11).
{ pkgs, lib, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "cosmic-ext-applet-minimon";
  version = "1.3.0";

  src = pkgs.fetchurl {
    url = "https://github.com/cosmic-utils/cosmic-ext-applet-minimon/releases/download/v${version}/${pname}_${version}_amd64.deb";
    hash = "sha256-4dOhTxMPG7FKyAsa7QnPo+Vp1ieC4sgChZrkZdnroNs=";
  };

  # autoAddDriverRunpath: GPU monitoring dlopens driver libs from /run/opengl-driver
  nativeBuildInputs = [ pkgs.dpkg pkgs.autoPatchelfHook pkgs.autoAddDriverRunpath ];
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
    description = "System monitor applet for the COSMIC Desktop Environment";
    homepage = "https://github.com/cosmic-utils/cosmic-ext-applet-minimon";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-ext-applet-minimon";
    platforms = [ "x86_64-linux" ];
  };
}
