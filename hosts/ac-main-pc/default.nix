{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/amd.nix
    ../../modules/gui/default.nix
    ../../modules/system/default.nix
    ../../modules/desktop/de/cosmic.nix
  ];

  networking.hostName = "ac-main-pc";
  services.cloudflare-warp.enable = true;
  services.resolved.enable = true;

  # Open ports for development
  networking.firewall.allowedTCPPorts = [
    9998 # Xdebug
  ];

  networking.hosts = {
    "127.0.0.10" = [
      "dev.carandclassic.com"
      "dev.api.carandclassic.com"
      "dev.lesanciennes.com"
      "internal.lesanciennes.com"
    ];
  };

  security.pki.certificateFiles = [ ./la.crt ./cnc.crt ];

  system.stateVersion = "24.05";

  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [ sshfs helm k3d kubectl ];

  fileSystems."/home/ac/Pi5" = {
    device = "ac@rpi5.local:/";
    fsType = "fuse.sshfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "_netdev"

      "allow_other"
      "reconnect"
      "ServerAliveInterval=15"
      "StrictHostKeyChecking=accept-new"

      "IdentityFile=/home/ac/.ssh/id_zenbook"
    ];
  };
}
