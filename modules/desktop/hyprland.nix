{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  services.displayManager.sddm.enable = true;

  environment.systemPackages = with pkgs; [ waybar wofi dunst wl-clipboard ];

}
