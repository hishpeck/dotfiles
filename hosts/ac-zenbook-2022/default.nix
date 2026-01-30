{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/gui/default.nix
    ../../modules/system/default.nix
    ../../modules/system/laptop.nix
    ../../modules/desktop/cosmic.nix
    # ../../modules/desktop/hyprland.nix
  ];

  networking.hostName = "ac-zenbook-2022";

  system.stateVersion = "24.05";
}
