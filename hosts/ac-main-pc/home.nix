{ pkgs, ... }: {
  imports = [
    ../../modules/home/cli/default.nix
    ../../modules/home/gui/default.nix
    ../../modules/home/private.nix
    ../../modules/home/work.nix
  ];

  programs.zsh.shellAliases = {
    car = "~/projects/carandclassic/carandclassic/bin/car";
  };

  xresources.properties = {
    "Xft.dpi" = 192;
  };

  home.stateVersion = "24.05";
}
