{ pkgs, ... }:
{
  imports = [
    ../../modules/home/cli/default.nix
    ../../modules/home/gui/default.nix
    ../../modules/home/work.nix
    ../../modules/home/laptop.nix
  ];

  home.stateVersion = "24.05";
}
