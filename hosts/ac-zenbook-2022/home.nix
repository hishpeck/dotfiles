{ pkgs, ... }: {
  imports =
    [ ../../modules/home/cli/default.nix ../../modules/desktop/private.nix ];

  home.stateVersion = "24.05";
}
