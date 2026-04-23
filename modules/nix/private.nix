{ pkgs, ... }:

{
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
