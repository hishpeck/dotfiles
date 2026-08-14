{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  services.upower.enable = true;

  # power-profiles-daemon is the standard for modern desktops (GNOME, KDE, COSMIC)
  # and integrates better with the amd-pstate driver on ASUS hardware.
  services.power-profiles-daemon.enable = true;

  systemd.services.disable-usb-wakeup = {
    description = "Disable USB wake triggers in /proc/acpi/wakeup";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "disable-usb-wakeup" ''
        for device in XHC0 XHC1 XHC2 XHC3 XHC4; do
          if grep -q "$device.*enabled" /proc/acpi/wakeup; then
            echo "$device" > /proc/acpi/wakeup
          fi
        done
      ''}";
      RemainAfterExit = true;
    };
  };

  boot.kernelParams = [ "asus_wmi.battery_charge_limit=80" ];

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger";
      disableWhileTyping = true;
    };
  };

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-elan;
    };
  };
  services.fwupd.enable = true;

  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    polkit-1.fprintAuth = true;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    pamixer
  ];

  hardware.enableAllFirmware = true;
}
