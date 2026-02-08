{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    slack
    notion
    zoom
    # wireguard
    cloudflare-warp
  ];
}

