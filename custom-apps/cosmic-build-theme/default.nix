{
  pkgs ? import <nixpkgs> { },
}:

# Reuses cosmic-settings-daemon's source tree and vendored crates, adding one
# binary to its cosmic-settings-daemon-config crate (which already depends on
# cosmic-theme). A new bin target doesn't touch Cargo.lock, so the upstream
# cargoDeps apply as-is and the tool always tracks the installed COSMIC's
# theme format — unlike cosmic-ctl, which is stuck on the pre-v2 layout.
let
  daemon = pkgs.cosmic-settings-daemon;
in
pkgs.rustPlatform.buildRustPackage {
  pname = "cosmic-build-theme";
  inherit (daemon) version src cargoDeps;

  postPatch = ''
    mkdir -p cosmic-settings-daemon-config/src/bin
    cp ${./build-theme.rs} cosmic-settings-daemon-config/src/bin/cosmic-build-theme.rs
  '';

  cargoBuildFlags = [
    "-p"
    "cosmic-settings-daemon-config"
    "--features"
    "greeter"
    "--bin"
    "cosmic-build-theme"
  ];
  doCheck = false;

  meta.mainProgram = "cosmic-build-theme";
}
