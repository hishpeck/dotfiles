{
  config,
  pkgs,
  lib,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  hardware.enableRedistributableFirmware = true;

  boot.kernelModules = [ "xe" ];

  boot.kernelParams = [
    "xe.force_probe=a840"
    "i915.force_probe=!a840"

    "i915.enable_dc=0"

    "i915.enable_fbc=0"

    "i915.enable_psr=0"
  ];
}
