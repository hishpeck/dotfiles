{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.system76-scheduler.enable = true;
  hardware.system76.power-daemon.enable = true;
}
