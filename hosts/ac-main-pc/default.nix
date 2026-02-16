{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/amd.nix
    ../../modules/gui/default.nix
    ../../modules/system/default.nix
    ../../modules/desktop/cosmic.nix
    # ../../modules/desktop/hyprland.nix
  ];

  networking.hostName = "ac-main-pc";

  system.stateVersion = "24.05";
}
