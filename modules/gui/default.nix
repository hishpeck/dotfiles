{ pkgs, ... }:

{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "ac" ];
  };

    home-manager.users.ac = {pkgs, ...}: {

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    google-chrome
    pavucontrol
  ];

  fonts.fontconfig.enable = true;

    };


}
