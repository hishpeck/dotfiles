{ lib, pkgs, ... }:

let
  # Each Pi directory gets its own sshfs mount (and so its own ssh connection +
  # sftp-server on the Pi). sftp-server is single-threaded, so with one mount of
  # the Pi's whole `/` a single stuck disk froze every path under it. Split
  # mounts keep a failing USB drive from blocking the others, and keep file
  # managers / recursive tools out of the Pi's /proc, /sys, /dev.
  #
  # Shared by every NixOS host that imports this module — keep paths identical
  # across devices.
  pi5Mounts = {
    home = "/home/ac";
    external_big = "/mnt/external_big";
    external1 = "/mnt/external1";
    external2 = "/mnt/external2";
  };

  mkPi5Mount = remotePath: {
    device = "ac@rpi5.local:${remotePath}";
    fsType = "fuse.sshfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5"
      "_netdev"

      "allow_other"
      # sshfs runs as root via systemd; present files as owned by local `ac`
      # (uid 1000, group `users`) instead of the Pi's raw ids. Access checks
      # still happen on the Pi as its `ac` user.
      "uid=1000"
      "gid=100"
      "reconnect"
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "StrictHostKeyChecking=accept-new"

      "ConnectTimeout=3"
      "IdentityFile=/home/ac/.ssh/id_zenbook"
    ];
  };
in
{
  services.zerotierone.enable = true;

  # ZeroTier defaults to MTU 2800, which causes packet fragmentation blackholes
  # on standard WAN/Wi-Fi networks (MTU ~1400-1500) and hangs SSH/SSHFS handshakes.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="zt*", ATTR{mtu}="1280"
  '';

  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [ sshfs ];

  fileSystems = lib.mapAttrs' (
    name: remotePath: lib.nameValuePair "/mnt/pi5/${name}" (mkPi5Mount remotePath)
  ) pi5Mounts;
}
