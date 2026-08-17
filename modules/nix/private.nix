{ pkgs, ... }:

{
  services.zerotierone.enable = true;

  # ZeroTier defaults to MTU 2800, which causes packet fragmentation blackholes
  # on standard WAN/Wi-Fi networks (MTU ~1400-1500) and hangs SSH/SSHFS handshakes.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="zt*", ATTR{mtu}="1280"
  '';

  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [ sshfs ];

  fileSystems."/home/ac/Pi5" = {
    device = "ac@rpi5.local:/";
    fsType = "fuse.sshfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=5"
      "_netdev"

      "allow_other"
      "reconnect"
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "StrictHostKeyChecking=accept-new"

      "ConnectTimeout=3"
      "IdentityFile=/home/ac/.ssh/id_zenbook"
      "KexAlgorithms=curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256"
    ];
  };
}
