{ pkgs, ... }:

{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # XDG Portal for screen sharing and file picker
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
  };

  # Display manager configuration
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Essential packages for Niri
  environment.systemPackages = with pkgs; [
    # Terminal
    kitty
    
    # Notifications
    dunst
    libnotify
    
    # Application launcher (using your existing walker)
    # walker is configured separately in modules/desktop/launcher/walker.nix
    
    # Screenshot utilities
    grim
    slurp
    swappy
    
    # Clipboard manager
    wl-clipboard
    cliphist
    
    # Status bar / Desktop shell (Noctalia will be configured separately)
    waybar
    
    # Network manager applet
    networkmanagerapplet
    
    # Wallpaper daemon
    swww
    swaybg
    
    # Screen locker
    swaylock
    
    # Audio control
    pavucontrol
    
    # Brightness control
    brightnessctl
    
    # Niri utilities
    nirius
    python3Packages.niriswitcher
  ];

  # Required services
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;
  
  # PipeWire for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable polkit for privilege escalation
  security.polkit.enable = true;
}
