# Prebuilt .deb from upstream releases (no Rust compile). Bumped by `pkg-update` (runs before niup).
# Replaces nixpkgs' 0.1.2, which busy-loops and pins cosmic-panel at ~30% CPU
# while any mic stream (e.g. noise suppression) is open — fixed upstream in
# 00124b2 and #22, see issue #18.
{ pkgs, lib, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "cosmic-ext-applet-privacy-indicator";
  version = "0.3.1";

  src = pkgs.fetchurl {
    url = "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator/releases/download/v${version}/${pname}_${version}-1_amd64.deb";
    hash = "sha256-Ed6IrqWgNRuHk87Tc1XGJae4NB9gfgFzLfoprjO/ZoA=";
  };

  nativeBuildInputs = [ pkgs.dpkg pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.pipewire pkgs.libxkbcommon pkgs.stdenv.cc.cc.lib ];
  # dlopen'd at runtime by libcosmic/winit, so autoPatchelf can't see them
  runtimeDependencies = [ pkgs.wayland pkgs.libGL pkgs.vulkan-loader pkgs.libxkbcommon ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall
    cp -r usr $out
    runHook postInstall
  '';

  meta = {
    description = "Privacy indicator applet for the COSMIC Desktop Environment";
    homepage = "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-ext-applet-privacy-indicator";
    platforms = [ "x86_64-linux" ];
  };
}
