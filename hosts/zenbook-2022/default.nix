{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/default.nix
    ../../modules/system/laptop.nix
    ../../modules/gui
    ../../modules/desktop/cosmic.nix
    # ../../modules/desktop/hyprland.nix
  ];

  networking.hostName = "ac-zenbook-2022";

  services.logind.lidSwitch = "suspend";

  system.stateVersion = "24.05";
}
