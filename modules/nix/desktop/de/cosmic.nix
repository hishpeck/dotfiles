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

  # NFS thumbnails would need patching cosmic-files (src/tab.rs `fs_kind` hardcodes
  # nfs/nfs4 as remote; upstream issue pop-os/cosmic-files#1150). Tried and
  # reverted 2026-11-13: building it from source here kept crashing.
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
