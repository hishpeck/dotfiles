{ pkgs, ... }: {
  imports =
    [ ../../modules/home/cli/default.nix ../../modules/home/gui/default.nix ../../modules/home/private.nix ];

  home.stateVersion = "24.05";
}
