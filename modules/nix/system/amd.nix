{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

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
