{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix/system/amd.nix
    ../../modules/nix/gui/default.nix
    ../../modules/nix/system/default.nix
    ../../modules/nix/system/laptop.nix
    ../../modules/nix/desktop/de/cosmic.nix
    ../../modules/nix/private.nix
  ];

  networking.hostName = "ac-zenbook-2022";

  # Resume from /var/lib/swapfile on ext4 root filesystem
  boot.resumeDevice = "/dev/disk/by-uuid/27a80fc1-21ad-4e0c-8c08-85865b16b712";
  boot.kernelParams = [
    # Physical offset of /var/lib/swapfile extent 0.
    # Recompute with `sudo filefrag -v /var/lib/swapfile | head -n4` if resized/recreated.
    "resume_offset=8654848"
  ];

  # Suspend-then-hibernate: sleep in s2idle for 1h for instant wake, then
  # hibernate to disk to stop battery drain while closed long-term.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  # RAM compression (ZRAM) for fast daily multitasking without SSD wear.
  # Has priority 5 so the kernel pages to compressed RAM first, leaving the
  # on-disk swapfile (priority -1) idle except as a fallback and hibernation target.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 5;
  };

  # AMD Rembrandt (Radeon 680M / DCN 3.1.2) driver workarounds:
  # - sg_display=0: Disables Scatter/Gather display memory handling which causes visual artifacts/flickering on Rembrandt APUs.
  # - dcdebugmask=0x10: Disables PSR / DCN idle power states that cause screen artifacts and panel flickering.
  #boot.kernelParams = [
  #  "amdgpu.sg_display=0"
  #  "amdgpu.dcdebugmask=0x10"
  #];

  system.stateVersion = "24.05";
}
