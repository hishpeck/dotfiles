{ lib, pkgs, ... }:

let
  # Pi 5 is shared by several Linux machines — keep mount paths identical on
  # every host importing this module.
  #
  # `rpi5.local` (mDNS) may resolve to the Pi's Wi-Fi address; pin its wired
  # eth0 address instead. Keep it stable with a DHCP reservation on the router.
  pi5Addr = "192.168.0.200";
  pi5 = "rpi5";

  # Disks: NFSv4, exported from the Pi's /etc/exports (LAN + ZeroTier only,
  # all_squash → ac). To add a disk, export it on the Pi and add it here.
  # NFS is kernel-side and multi-threaded, far faster than sshfs for large
  # media files, and `soft` makes a dead disk return EIO instead of freezing
  # every process that touches the mount.
  pi5NfsMounts = {
    external_big = "/mnt/external_big";
  };

  # Home dir: sshfs (no NFS export needed, auth via ssh key).
  pi5SshfsMounts = {
    home = "/home/ac";
  };

  automountOpts = [
    "x-systemd.automount"
    "noauto"
    "x-systemd.idle-timeout=300"
    "x-systemd.mount-timeout=10"
    "_netdev"
  ];

  mkNfsMount = remotePath: {
    device = "${pi5}:${remotePath}";
    fsType = "nfs";
    options = automountOpts ++ [
      "nfsvers=4.2"
      "soft"
      "timeo=150" # 15s per try (deciseconds)
      "retrans=3"
    ];
  };

  mkSshfsMount = remotePath: {
    device = "ac@${pi5}:${remotePath}";
    fsType = "fuse.sshfs";
    options = automountOpts ++ [
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

  mkMounts =
    mk: mounts:
    lib.mapAttrs' (name: remotePath: lib.nameValuePair "/mnt/pi5/${name}" (mk remotePath)) mounts;
in
{
  services.zerotierone.enable = true;

  # ZeroTier defaults to MTU 2800, which causes packet fragmentation blackholes
  # on standard WAN/Wi-Fi networks (MTU ~1400-1500) and hangs SSH/SSHFS handshakes.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="zt*", ATTR{mtu}="1280"
  '';

  networking.hosts.${pi5Addr} = [ pi5 ];

  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [ sshfs ];

  fileSystems = mkMounts mkNfsMount pi5NfsMounts // mkMounts mkSshfsMount pi5SshfsMounts;
}
