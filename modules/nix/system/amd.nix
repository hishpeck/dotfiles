{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Load the GPU driver in initrd so Plymouth starts on the real KMS device
  # instead of simpledrm, which gets torn down mid-boot when amdgpu loads.
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
      rocmPackages.clr
    ];
  };

  hardware.cpu.amd.updateMicrocode = true;
}
