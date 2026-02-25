{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/intel.nix
    ../../modules/gui/default.nix
    ../../modules/system/default.nix
    ../../modules/system/laptop.nix
    ../../modules/desktop/cosmic.nix
    # ../../modules/desktop/hyprland.nix
  ];

  networking.hostName = "ac-zenbook-2025";
  services.cloudflare-warp.enable = true;

  networking.hosts = {
    "127.0.0.10" = [
      "dev.carandclassic.com"
      "dev.api.carandclassic.com"
      "dev.lesanciennes.com"
      "internal.lesanciennes.com"
    ];
  };

  security.pki.certificateFiles = [
    ./la.crt
    ./cnc.crt
  ];

  system.stateVersion = "24.05";
}
