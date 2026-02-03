{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ telegram-desktop discord steam lychee-slicer blender uvtools freecad ];
}

