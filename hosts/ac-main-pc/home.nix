{ pkgs, ... }: {
  imports = [
    ../../modules/home/cli/default.nix
    ../../modules/desktop/private.nix
    ../../modules/desktop/work.nix
  ];

  home.stateVersion = "24.05";
}
