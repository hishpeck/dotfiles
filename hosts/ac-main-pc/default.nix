{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix/system/amd.nix
    ../../modules/nix/gui/default.nix
    ../../modules/nix/system/default.nix
    ../../modules/nix/desktop/de/cosmic.nix
    ../../modules/nix/work.nix
    ../../modules/nix/private.nix
  ];

  networking.hostName = "ac-main-pc";
  services.resolved.enable = true;

  # Open ports for development
  networking.firewall.allowedTCPPorts = [
    9998 # Xdebug
  ];

  security.pki.certificateFiles = [ ./la.crt ./cnc.crt ];

  system.stateVersion = "24.05";
}
