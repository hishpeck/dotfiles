{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix/system/amd.nix
    ../../modules/nix/gui/default.nix
    ../../modules/nix/system/default.nix
    ../../modules/nix/system/laptop.nix
    ../../modules/nix/desktop/de/cosmic.nix
    ../../modules/nix/private.nix
  ];

  networking.hostName = "ac-zenbook-2022";

  system.stateVersion = "24.05";
}
