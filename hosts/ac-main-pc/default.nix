{ pkgs, ... }:

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
  boot.kernelParams = [ "drm.debug=0x106" ];
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

  system.stateVersion = "24.05";
}
