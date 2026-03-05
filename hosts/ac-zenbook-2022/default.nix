{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/amd.nix
    ../../modules/gui/default.nix
    ../../modules/system/default.nix
    ../../modules/system/laptop.nix
    ../../modules/desktop/cosmic.nix
    # ../../modules/desktop/hyprland.nix
  ];

  networking.hostName = "ac-zenbook-2022";

  system.stateVersion = "24.05";

  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [ sshfs ];

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
