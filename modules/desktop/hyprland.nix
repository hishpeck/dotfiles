{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };

  environment.systemPackages = with pkgs; [
    kitty       
    rofi
    waybar      
    dunst      
    swww      
    libnotify
    networkmanagerapplet 
  ];
}
