{ pkgs, ... }:
{
  imports = [
    ../../modules/home/cli/default.nix
    ../../modules/desktop/work.nix
  ];

  programs.zsh.shellAliases = {
    car = "~/projects/carandclassic/bin/car";
  };

  home.stateVersion = "24.05";
}
