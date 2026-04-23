{ pkgs, ... }: {
  imports = [
    ../../modules/home/cli/default.nix
    ../../modules/home/gui/default.nix
    ../../modules/home/private.nix
    ../../modules/home/work.nix
  ];

  xresources.properties = {
    "Xft.dpi" = 192;
  };

  home.stateVersion = "24.05";
}
