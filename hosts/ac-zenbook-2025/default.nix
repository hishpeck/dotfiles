{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix/system/intel.nix
    ../../modules/nix/gui/default.nix
    ../../modules/nix/system/default.nix
    ../../modules/nix/system/laptop.nix
    ../../modules/nix/desktop/de/cosmic.nix
    # ../../modules/nix/desktop/wm/hyprland.nix
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

  environment.systemPackages = with pkgs; [ helm k3d kubectl ];

  security.pki.certificateFiles = [ ./la.crt ./cnc.crt ];

  system.stateVersion = "24.05";
}
