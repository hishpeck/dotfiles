{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    slack
    notion
    zoom
    cloudflare-warp
  ];
}
