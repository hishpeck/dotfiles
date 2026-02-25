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
  services.cloudflare-warp.enable = true;

  networking.hosts = {
    "127.0.0.10" = [
      "dev.carandclassic.com"
      "dev.api.carandclassic.com"
      "dev.lesanciennes.com"
      "internal.lesanciennes.com"
    ];
  };

  security.pki.certificateFiles = [ ./la.crt ./cnc.crt ];

  system.stateVersion = "24.05";
}
