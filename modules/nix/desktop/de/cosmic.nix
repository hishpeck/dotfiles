{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.system76-scheduler.enable = true;
  hardware.system76.power-daemon.enable = true;

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals =
      [ pkgs.xdg-desktop-portal-cosmic pkgs.xdg-desktop-portal-gtk ];

    config.common.default = [ "cosmic" ];
  };

  environment.pathsToLink = [ "/share/thumbnailers" ];
}
