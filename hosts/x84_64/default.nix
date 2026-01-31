{ pkgs, ... }: {
  imports = [ ../../modules/home/cli/default.nix ];

  targets.genericLinux.enable = true;

  home.stateVersion = "24.05";
}
