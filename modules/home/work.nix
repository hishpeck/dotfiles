{ config, pkgs, ... }:

{
  programs.zsh.shellAliases = {
    car = "~/projects/carandclassic/carandclassic/bin/car";
  };

  home.packages = with pkgs; [
    slack
    notion
    claude-code

    font-adobe-100dpi
    font-adobe-75dpi
    font-alias
    font-bh-ttf
  ];
}
