{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono 
    
    chrome
    wofi      
    waybar   
    pavucontrol 
  ];

  fonts.fontconfig.enable = true;
}
