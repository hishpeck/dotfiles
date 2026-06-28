{ config, pkgs, ... }:

{
  # Zapewnia wsparcie klienta NFS na poziomie jądra NixOS
  boot.supportedFilesystems = [ "nfs" ];

  fileSystems."/home/ac/Pi5/mnt/external2" = {
    device = "rpi5.local:/mnt/external2";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=5"
      "_netdev"
      "nfsvers=4.2"
    ];
  };
}
