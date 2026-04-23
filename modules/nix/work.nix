{ pkgs, ... }:

{
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
}
