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
    # carandclassic `car worktree` stacks (each on its own port).
    "127.0.0.1" = [ "worktree.dev.carandclassic.com" ];
  };

  environment.systemPackages = with pkgs; [ helm k3d kubectl ];
}
