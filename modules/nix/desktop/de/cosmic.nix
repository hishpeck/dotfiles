{ pkgs, lib, ... }:

let
  cosmic-applet-music-player = pkgs.rustPlatform.buildRustPackage {
    pname = "cosmic-ext-applet-music-player";
    version = "0-unstable-2026-05-07";

    src = pkgs.fetchFromGitHub {
      owner = "Ebbo";
      repo = "cosmic-applet-music-player";
      rev = "1fe94a89a85be34b867ee94268e46e7fd72e88b8";
      hash = "sha256-GAIzV/BdU4SOV6P+qNGWmPzF5mvNym9D99/7Hg5/Amc=";
    };

    cargoHash = "sha256-Cs9g2w480jquSNyEG41WqOEMPQ/BJKcOgN8VnCfZBLQ=";

    nativeBuildInputs = [
      pkgs.just
      pkgs.libcosmicAppHook
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.openssl
      pkgs.dbus
      pkgs.libpulseaudio
    ];

    dontUseJustBuild = true;
    dontUseJustCheck = true;

    justFlags = [
      "--set"
      "prefix"
      (builtins.placeholder "out")
      "--set"
      "bin-src"
      "target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-applet-music-player"
    ];

    meta = {
      description = "Music player applet for the COSMIC Desktop Environment";
      homepage = "https://github.com/Ebbo/cosmic-applet-music-player";
      license = lib.licenses.gpl3Only;
      mainProgram = "cosmic-ext-applet-music-player";
      platforms = lib.platforms.linux;
    };
  };

  cosmic-ext-whether = pkgs.rustPlatform.buildRustPackage {
    pname = "cosmic-ext-whether";
    version = "0-unstable-2026-05-07";

    src = pkgs.fetchFromGitHub {
      owner = "nwxnw";
      repo = "cosmic-ext-whether";
      rev = "92afacb3f77f5cb0c4e6bae05424a32401dcf5c3";
      hash = "sha256-UaxdnZrpnjlR0/jdg0aRg4JAbcbD9BHC1af0tIETPGU=";
    };

    cargoHash = "sha256-7CSXz8QDmTvmnY/TjJMdYhM5ZyKBW8YdkYcKzKcAc18=";

    nativeBuildInputs = [
      pkgs.just
      pkgs.libcosmicAppHook
    ];

    dontUseJustBuild = true;
    dontUseJustCheck = true;

    justFlags = [
      "--set"
      "prefix"
      (builtins.placeholder "out")
      "--set"
      "bin-src"
      "target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-whether"
    ];

    meta = {
      description = "Weather applet for the COSMIC Desktop Environment";
      homepage = "https://github.com/nwxnw/cosmic-ext-whether";
      license = lib.licenses.gpl3Only;
      mainProgram = "cosmic-ext-whether";
      platforms = lib.platforms.linux;
    };
  };

  cosmic-ext-applet-clipboard-manager = pkgs.rustPlatform.buildRustPackage {
    pname = "cosmic-ext-applet-clipboard-manager";
    version = "0-unstable-2026-05-07";

    src = pkgs.fetchFromGitHub {
      owner = "cosmic-utils";
      repo = "clipboard-manager";
      rev = "d473e8f09e8bc2289a76707898063a13714c79dc";
      hash = "sha256-RNRSShrT7wS4GmQNd3tXtT8G/4qLM9zxntXgBQ6C7ps=";
    };

    cargoHash = "sha256-+yqFV8HdPjkVny+6FKkZFEQAq1rwe7JXmoTJ7zge8bg=";

    env.CLIPBOARD_MANAGER_COMMIT = "unknown";

    nativeBuildInputs = [
      pkgs.just
      pkgs.libcosmicAppHook
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.sqlite
      pkgs.systemd
    ];

    dontUseJustBuild = true;
    dontUseJustCheck = true;

    justFlags = [
      "--set"
      "prefix"
      (builtins.placeholder "out")
      "--set"
      "cargo-target-dir"
      "target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}"
      "--set"
      "CLIPBOARD_MANAGER_COMMIT"
      "unknown"
    ];

    meta = {
      description = "Clipboard manager applet for the COSMIC Desktop Environment";
      homepage = "https://github.com/cosmic-utils/clipboard-manager";
      license = lib.licenses.gpl3Only;
      mainProgram = "cosmic-ext-applet-clipboard-manager";
      platforms = lib.platforms.linux;
    };
  };

  cosmic-viewer = pkgs.rustPlatform.buildRustPackage {
    pname = "cosmic-viewer";
    version = "0-unstable-2026-07-29";

    src = pkgs.fetchFromGitHub {
      owner = "pop-os";
      repo = "cosmic-viewer";
      rev = "6c999eb5100353260d481077f1820ef95ee68ea7";
      hash = "sha256-KUfWA6ZZMSnzagFJNlHJoWJTcMP2jTd0j7BYTYKfBF4=";
    };

    cargoHash = "sha256-Ws8ozNY3hwxdkb5g6RuSDyzt3IRk1svm3byXkIpknQE=";

    # Upstream builds libheif-rs with the "embedded-libheif" feature, which
    # vendor-builds libheif from source along with ~10 codec libraries (some
    # of which, e.g. uvg266/vvdec, aren't packaged in nixpkgs at all). Link
    # against nixpkgs' own libheif via pkg-config instead.
    postPatch = ''
      substituteInPlace Cargo.toml \
        --replace-fail \
          'libheif-rs = { version = "2.7.0", default-features = false, features = [
  "embedded-libheif",
  "v1_17",
] }' \
          'libheif-rs = { version = "2.7.0", features = ["v1_17"] }'
    '';

    # turbojpeg-sys also defaults to vendor-building libjpeg-turbo via cmake;
    # point it at nixpkgs' libjpeg-turbo via pkg-config instead.
    env.TURBOJPEG_SOURCE = "pkg-config";

    nativeBuildInputs = [
      pkgs.just
      pkgs.libcosmicAppHook
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.glib
      pkgs.libheif
      pkgs.libjpeg_turbo
    ];

    dontUseJustBuild = true;
    dontUseJustCheck = true;

    justFlags = [
      "--set"
      "prefix"
      (builtins.placeholder "out")
      "--set"
      "cargo-target-dir"
      "target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}"
    ];

    meta = {
      description = "Image viewer for the COSMIC Desktop Environment";
      homepage = "https://github.com/pop-os/cosmic-viewer";
      license = lib.licenses.gpl3Only;
      mainProgram = "cosmic-viewer";
      platforms = lib.platforms.linux;
    };
  };
in
{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  environment.cosmic.excludePackages = [
    pkgs.cosmic-term
    pkgs.cosmic-player
    pkgs.cosmic-edit
    pkgs.cosmic-reader
  ];

  services.gnome.gnome-keyring.enable = true;
  services.system76-scheduler.enable = true;

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-cosmic
      pkgs.xdg-desktop-portal-gtk
    ];

    config.common.default = [ "cosmic" ];
  };

  environment.pathsToLink = [ "/share/thumbnailers" ];

  environment.systemPackages = [
    pkgs.cosmic-ext-applet-minimon
    pkgs.cosmic-ext-applet-privacy-indicator
    cosmic-applet-music-player
    cosmic-ext-whether
    cosmic-ext-applet-clipboard-manager
    cosmic-viewer
  ];
}
