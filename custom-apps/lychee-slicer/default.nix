{ pkgs, ... }:

let
  version = "8.0.3";
  pname = "lycheeslicer";

  src = pkgs.fetchurl {
    url = "https://mango-lychee.nyc3.cdn.digitaloceanspaces.com/LycheeSlicer-${version}-x86_64.GLIB-235.AppImage";
    hash = "sha256-djXiUB2hak7pcmmHQAm/bWOk7b9YHHRQbgriLRN11Ik=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

  # Lychee regenerates this on every start (OAuth login callback) with Exec=
  # pointing at the unwrapped binary, which can't run outside the FHS env.
  urlHandler = pkgs.writeText "lycheeslicer-url-handler.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=LycheeSlicer URL Handler
    Exec=lycheeslicer %u
    StartupNotify=false
    Terminal=false
    NoDisplay=true
    MimeType=x-scheme-handler/lycheeslicer;
  '';
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs =
    pkgs: with pkgs; [
      libxshmfence
      wayland
      wayland-protocols
    ];

  extraPreBwrapCmds = ''
    # Install the URL handler read-only, so Lychee can't overwrite it with a broken one.
    handler="$HOME/.local/share/applications/lycheeslicer-url-handler.desktop"
    ${pkgs.coreutils}/bin/rm -f "$handler"
    ${pkgs.coreutils}/bin/install -Dm444 ${urlHandler} "$handler"

    # The license check reads the machine UUID only from /var/lib/dbus/machine-id,
    # which NixOS doesn't have. The host /var is bind-mounted, so bwrap can't add it
    # there: put a tmpfs over /var/lib, rebind the host entries and add machine-id.
    varlib_mounts=(--tmpfs /var/lib)
    for d in /var/lib/*; do
      [[ $d == /var/lib/dbus ]] || varlib_mounts+=(--bind "$d" "$d")
    done
    varlib_mounts+=(--ro-bind /etc/machine-id /var/lib/dbus/machine-id)
  '';

  extraBwrapArgs = [ "\"\${varlib_mounts[@]}\"" ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/scalable/apps/LycheeSlicer.svg \
      $out/share/icons/hicolor/scalable/apps/lycheeslicer.svg
  '';
}
