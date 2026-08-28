{ config, pkgs, lib, ... }:
let
  inherit (import ../../theme-values.nix) flavor accent;

  nixosCatppuccinPlymouth = pkgs.runCommand "nixos-catppuccin-plymouth" { } ''
        mkdir -p $out/share/plymouth/themes/nixos-catppuccin
        cat > $out/share/plymouth/themes/nixos-catppuccin/nixos-catppuccin.plymouth << EOF
    [Plymouth Theme]
    Name=NixOS Catppuccin
    Description=Spinning NixOS logo on Catppuccin Mocha background
    ModuleName=two-step

    [two-step]
    Font=Cantarell 20
    ImageDir=${pkgs.nixos-bgrt-plymouth}/share/plymouth/themes/nixos-bgrt/images
    HorizontalAlignment=.5
    VerticalAlignment=.5
    Transition=none
    TransitionDuration=0.0
    BackgroundStartColor=0x1e1e2e
    BackgroundEndColor=0x1e1e2e
    ProgressBarBackgroundColor=0x45475a
    ProgressBarForegroundColor=0xf5c2e7
    MessageBelowAnimation=true

    [boot-up]
    UseEndAnimation=false

    [shutdown]
    UseEndAnimation=false

    [reboot]
    UseEndAnimation=false
    EOF
  '';
in {
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    max-substitution-jobs = 128; # Default is 16
    http-connections = 128; # Default is 25
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [
      "https://cache.nixos.org/"
      "https://cosmic.cachix.org/"
      "https://hishpeck.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cosmic.cachix.org-1:D7qyvniWny9W6jnP799Aunmdfn35p0qT3Y6E3n5M9f4="
      "hishpeck.cachix.org-1:mZfdMDcOQs9JIpXeT0T/F0DgAXaaTVYblSXFnIr9y7E="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16384;
  }];

  boot.kernel.sysctl = { "vm.swappiness" = 10; };

  networking.networkmanager.enable = true;

  # Default 5s is too short for COSMIC's session manager to ask apps (esp.
  # the browser) to close gracefully before logind SIGKILLs them, which is
  # what causes "session not closed properly" warnings on next launch.
  services.logind.settings.Login.InhibitDelayMaxSec = 20;

  # Without this, cosmic-session can hang watching a missing GeoClue2 D-Bus
  # service during shutdown, stalling session-N.scope until systemd's ~91s
  # timeout mass-SIGKILLs the whole session (browser included) instead of
  # letting it close gracefully. See nixpkgs#415901.
  services.geoclue2.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  users.users.ac = {
    isNormalUser = true;
    description = "ac";
    extraGroups =
      [ "networkmanager" "wheel" "docker" "video" "render" "uinput" ];
    shell = pkgs.zsh;
  };

  # Lets vicinae's input-server helper inject keystrokes (paste emoji/clipboard
  # entries directly instead of just copying) via /dev/uinput — grants the
  # `uinput` group access to it, no setcap/capabilities needed.
  hardware.uinput.enable = true;

  programs.zsh.enable = true;

  virtualisation.docker.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Auto-mount removable media
  # services.udisks2.enable = true;

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    NH_FLAKE = "$HOME/dotfiles";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    home-manager
    nps
    cachix
    nh
    nix-output-monitor
    nvd
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;

  boot.kernelParams = [ "quiet" "splash" ];
  boot.initrd.systemd.enable = true;
  boot.plymouth = {
    enable = true;
    theme = "nixos-catppuccin";
    themePackages = [ nixosCatppuccinPlymouth ];
  };

  catppuccin = {
    enable = true;
    autoEnable = false;
    inherit flavor accent;
    limine.enable = true;
  };
}
