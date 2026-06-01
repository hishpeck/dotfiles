{ pkgs, ... }:

{
  imports = [ ./kitty.nix ];

  home.packages = with pkgs; [
    lato
    nerd-fonts.fira-code
    noto-fonts-cjk-sans

    google-chrome
    pavucontrol
    (pkgs.callPackage ../../../custom-apps/upnote/default.nix { })

    p7zip
    udisks # CLI tool for managing disks
  ];

  fonts.fontconfig.enable = true;

  # Auto-mount removable media
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never"; # Change to "auto" if you want a system tray icon
  };

  # Autostart 1Password
  xdg.configFile."autostart/1password.desktop".text = ''
    [Desktop Entry]
    Name=1Password
    Exec=1password --silent
    Terminal=false
    Type=Application
    Icon=1password
    StartupWMClass=1Password
    Comment=Password manager and secure wallet
    Categories=Office;
    X-GNOME-Autostart-enabled=true
  '';
}
