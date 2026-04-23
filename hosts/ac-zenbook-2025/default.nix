{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix/system/intel.nix
    ../../modules/nix/gui/default.nix
    ../../modules/nix/system/default.nix
    ../../modules/nix/system/laptop.nix
    ../../modules/nix/desktop/de/cosmic.nix
    ../../modules/nix/work.nix
    # ../../modules/nix/desktop/wm/hyprland.nix
  ];

  networking.hostName = "ac-zenbook-2025";

  security.pki.certificateFiles = [ ./la.crt ./cnc.crt ];

  system.stateVersion = "24.05";
}
