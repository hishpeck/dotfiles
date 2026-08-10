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

  # AMD Rembrandt (Radeon 680M / DCN 3.1.2) driver workarounds:
  # - sg_display=0: Disables Scatter/Gather display memory handling which causes visual artifacts/flickering on Rembrandt APUs.
  # - dcdebugmask=0x10: Disables PSR / DCN idle power states that cause screen artifacts and panel flickering.
  #boot.kernelParams = [
  #  "amdgpu.sg_display=0"
  #  "amdgpu.dcdebugmask=0x10"
  #];

  system.stateVersion = "24.05";
}
