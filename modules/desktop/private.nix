{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    telegram-desktop
    discord
    steam
    blender
    freecad
    (pkgs.callPackage ../../custom-apps/lychee-slicer/default.nix { })
    (pkgs.callPackage ../../custom-apps/uvtools/default.nix { })
  ];
}

