{ pkgs, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "ac" ];
  };

  home-manager.users.ac = { pkgs, ... }: {
    home.packages = with pkgs; [
      lato
      nerd-fonts.fira-code
      noto-fonts-cjk-sans

      google-chrome
      pavucontrol

      p7zip
    ];

    fonts.fontconfig.enable = true;

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
  };
}
