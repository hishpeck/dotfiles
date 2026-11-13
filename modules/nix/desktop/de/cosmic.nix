{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  environment.cosmic.excludePackages =
    [ pkgs.cosmic-term pkgs.cosmic-player pkgs.cosmic-edit pkgs.cosmic-reader ];

  services.gnome.gnome-keyring.enable = true;
  services.system76-scheduler.enable = true;

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals =
      [ pkgs.xdg-desktop-portal-cosmic pkgs.xdg-desktop-portal-gtk ];

    config.common.default = [ "cosmic" ];
  };

  # COSMIC Files hardcodes nfs/nfs4 as "remote" (src/tab.rs `fs_kind`) and
  # never thumbnails remote files — no setting for it. Our only NFS mounts are
  # the Pi disks on the LAN, fast enough to thumbnail, so treat NFS as local.
  # Builds cosmic-files from source; --replace-fail breaks the build loudly if
  # upstream changes that line.
  nixpkgs.overlays = [
    (final: prev: {
      cosmic-files = prev.cosmic-files.overrideAttrs (old: {
        # ld.bfd fails linking cosmic-files-applet locally ("failed to set
        # dynamic section sizes"); mold links it fine.
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.mold ];
        env = (old.env or { }) // { RUSTFLAGS = "-C link-arg=-fuse-ld=mold"; };
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/tab.rs \
            --replace-fail '"nfs" | "nfs4" => FsKind::Remote' '"nfs" | "nfs4" => FsKind::Local'
        '';
      });
    })
  ];

  environment.pathsToLink = [ "/share/thumbnailers" ];

  environment.systemPackages = [
    pkgs.cutecosmic
    pkgs.ffmpegthumbnailer # video thumbnails in COSMIC Files
    (pkgs.callPackage ../../../../custom-apps/cosmic-ext-applet-minimon { })
    (pkgs.callPackage ../../../../custom-apps/cosmic-ext-applet-privacy-indicator { })
    (pkgs.callPackage ../../../../custom-apps/cosmic-media-now-playing-applet { })
    (pkgs.callPackage ../../../../custom-apps/cosmic-ext-whether { })
  ];
}
