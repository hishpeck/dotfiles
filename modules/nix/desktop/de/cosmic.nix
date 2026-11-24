{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  environment.cosmic.excludePackages =
    [ pkgs.cosmic-term pkgs.cosmic-player pkgs.cosmic-edit pkgs.cosmic-reader ];

  services.gnome.gnome-keyring.enable = true;
  services.system76-scheduler.enable = true;

  services.dbus.enable = true;

  nixpkgs.overlays = [
    # Backport cosmic-protocols 815b2c5 into the portal's vendored client-toolkit:
    # destroy a finished frame before waking the screencast thread, else it can send
    # create_frame first → protocol error → portal crash → frozen screen share.
    # shortcut: remove once xdg-desktop-portal-cosmic's Cargo.lock includes 815b2c5.
    (final: prev: {
      xdg-desktop-portal-cosmic = prev.xdg-desktop-portal-cosmic.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          patch -p1 -d "$(echo $NIX_BUILD_TOP/$(stripHash $cargoDeps)/*/cosmic-client-toolkit-*)" \
            < ${./cctk-destroy-frame-before-callback.patch}
        '';
      });
    })

    # COSMIC Files hardcodes nfs/nfs4 as "remote" (src/tab.rs `fs_kind`) and never
    # thumbnails remote files — no setting for it (pop-os/cosmic-files#1150). Our
    # only NFS mounts are the Pi disks on the LAN, fast enough to thumbnail, so
    # treat NFS as local. Builds cosmic-files from source; --replace-fail breaks
    # the build loudly if upstream changes that line. Drop once #1150 adds a setting.
    (final: prev: {
      cosmic-files = prev.cosmic-files.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/tab.rs \
            --replace-fail '"nfs" | "nfs4" => FsKind::Remote' '"nfs" | "nfs4" => FsKind::Local'
        '';
      });
    })
  ];

  xdg.portal = {
    enable = true;

    extraPortals =
      [ pkgs.xdg-desktop-portal-cosmic pkgs.xdg-desktop-portal-gtk ];

    config.common.default = [ "cosmic" ];
  };

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
