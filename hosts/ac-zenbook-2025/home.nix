{ pkgs, ... }:
{
  imports = [
    ../../modules/home/cli/default.nix
    ../../modules/home/gui/default.nix
    ../../modules/home/work.nix
  ];

  programs.zsh.shellAliases = {
    car = "~/projects/carandclassic/bin/car";
  };

  home.stateVersion = "24.05";
}
