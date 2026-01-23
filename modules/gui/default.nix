{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    google-chrome
    pavucontrol
  ];

  fonts.fontconfig.enable = true;
}
