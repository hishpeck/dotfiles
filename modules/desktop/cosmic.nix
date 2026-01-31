{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.system76-scheduler.enable = true;
  hardware.system76.power-daemon.enable = true;

  xdg.portal = {
    enable = true;

    # Add the COSMIC portal backend explicitly
    extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];

    # Tell the system: "If anyone asks for a portal, use COSMIC"
    config.common.default = [ "cosmic" ];
  };
}
