{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix/system/amd.nix
    ../../modules/nix/gui/default.nix
    ../../modules/nix/system/default.nix
    ../../modules/nix/desktop/de/cosmic.nix
    ../../modules/nix/work.nix
    ../../modules/nix/private.nix
  ];

  networking.hostName = "ac-main-pc";

  # Enable crash dumps to capture kernel panics (suspected amdgpu/DCN 4.0.1 issue)
  boot.crashDump.enable = true;
  # Log GPU display/KMS/DP events to help diagnose the crash on next occurrence
  # dc_debug_mask=0x10 works around AMD DCN 4.0.1 mpc2_assert_idle_mpcc timeout bug —
  # causes panel flicker, screen-share hard crashes, and Slack huddle stutters.
  # Remove once the upstream amdgpu DCN 4.0.1 MPC idle fix lands in the kernel.
  boot.kernelParams = [ "drm.debug=0x106" "amdgpu.dc_debug_mask=0x10" ];
  services.resolved.enable = true;

  # Open ports for development
  networking.firewall.allowedTCPPorts = [
    9998 # Xdebug
  ];

  security.pki.certificateFiles = [
    ./la.crt
    ./cnc.crt
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

  system.stateVersion = "24.05";
}
