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
  };

  environment.systemPackages = with pkgs; [
    waybar
    dunst
    swww
    libnotify
    networkmanagerapplet
  ];

  wayland.windowManager.hyprland.settings = {
    bind = [
      "SUPER, Space, exec, walker"
      "SUPER, ;, exec, walker --modules emojis"
    ];
  };
}
