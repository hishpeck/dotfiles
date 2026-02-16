{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    slack
    notion
    zoom
    cloudflare-warp

    font-adobe-100dpi
    font-adobe-75dpi
    font-alias
    font-bh-ttf
  ];
}
