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
  # Load the GPU driver in initrd so Plymouth starts on the real KMS device.
  # Otherwise it starts on simpledrm, which gets torn down mid-boot when xe
  # loads after switch-root — the splash vanishes and you get a black screen.
  boot.initrd.kernelModules = [ "xe" ];

  boot.kernelParams = [
    "xe.force_probe=a840"
    "i915.force_probe=!a840"

    "i915.enable_dc=0"

    "i915.enable_fbc=0"

    "i915.enable_psr=0"
  ];

  hardware.cpu.intel.updateMicrocode = true;
}
