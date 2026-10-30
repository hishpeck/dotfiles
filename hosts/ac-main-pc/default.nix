{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix/system/amd.nix
    ../../modules/nix/gui/default.nix
    ../../modules/nix/system/default.nix
    ../../modules/nix/desktop/de/cosmic.nix
    ../../modules/nix/private.nix
  ];

  networking.hostName = "ac-main-pc";

  # Enable crash dumps to capture kernel panics (suspected amdgpu/DCN 4.0.1 issue)
  boot.crashDump.enable = true;
  # Log GPU display/KMS/DP events to help diagnose the crash on next occurrence
  # dc_debug_mask=0x10 works around AMD DCN 4.0.1 mpc2_assert_idle_mpcc timeout bug —
  # causes panel flicker, screen-share hard crashes, and Slack huddle stutters.
  # Remove once the upstream amdgpu DCN 4.0.1 MPC idle fix lands in the kernel.
  boot.kernelParams = [
    "drm.debug=0x106"
    "amdgpu.dc_debug_mask=0x10"
  ];
  services.resolved.enable = true;

  # Open ports for development
  networking.firewall.allowedTCPPorts = [
    9998 # Xdebug
  ];

  # DroidCam virtual camera for using phone as webcam
  programs.droidcam.enable = true;

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.loader.limine = {
    enable = true;
    maxGenerations = 3;
    secureBoot = {
      enable = true;
      sbctl = pkgs.sbctl.override { databasePath = "/var/lib/sbctl"; };
    };
  };

  environment.systemPackages = [ (pkgs.sbctl.override { databasePath = "/var/lib/sbctl"; }) ];

  # 128GB RAM and no hibernation — skip the shared /var/lib/swapfile.
  swapDevices = lib.mkForce [ ];

  # Extra data disks. nofail so a missing/dirty disk never blocks boot.
  # NTFS disks are shared with Windows — disable Windows Fast Startup/hibernation,
  # otherwise ntfs3 refuses to mount them read-write.
  # No windows_names: Proton writes filenames containing ':' into compatdata.
  fileSystems =
    let
      ntfs = uuid: {
        device = "/dev/disk/by-uuid/${uuid}";
        fsType = "ntfs3";
        options = [ "uid=1000" "gid=100" "umask=022" "nofail" "x-systemd.device-timeout=5s" ];
      };
    in
    {
      "/mnt/big-boi" = ntfs "EE5CA0545CA018FB";
      "/mnt/big-quick-boi" = ntfs "2CF23475F234457C";
      "/mnt/ntfs-1tb" = ntfs "70C497AAC49770D8";
      "/mnt/windows" = ntfs "0E5ECEEB5ECECB23";
      "/mnt/data" = {
        device = "/dev/disk/by-uuid/2270ce9f-0f40-4ff4-9d98-9d5d56b3623c";
        fsType = "ext4";
        options = [ "nofail" "x-systemd.device-timeout=5s" ];
      };
    };

  system.stateVersion = "24.05";
}
