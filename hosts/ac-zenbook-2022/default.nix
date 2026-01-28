{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/default.nix
    ../../modules/system/laptop.nix
    ../../modules/desktop/cosmic.nix
    # ../../modules/desktop/hyprland.nix
  ];

  networking.hostName = "ac-zenbook-2022";

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  system.stateVersion = "24.05";
}
