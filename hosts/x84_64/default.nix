{ pkgs, ... }: {
  imports = [ ../../modules/cli/default.nix ];

  targets.genericLinux.enable = true;

  home.stateVersion = "24.05";
}
