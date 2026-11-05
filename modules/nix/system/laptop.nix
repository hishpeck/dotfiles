{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.edgepad.nixosModules.default ];

  networking.networkmanager.enable = true;

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

  # After resume from hibernate the ASUS EC comes back on its own default
  # thermal policy while sysfs/power-profiles-daemon still report the old
  # profile, so the fan stays slow under load. Bounce the profile so asus-wmi
  # writes it to the EC again (writing the same value can be a no-op).
  powerManagement.resumeCommands = ''
    p=/sys/firmware/acpi/platform_profile
    if [ -w "$p" ]; then
      cur=$(cat "$p")
      [ "$cur" = balanced ] && tmp=quiet || tmp=balanced
      echo "$tmp" > "$p"
      echo "$cur" > "$p"
    fi
  '';

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger";
      disableWhileTyping = true;
    };
  };

  # Touchpad edge sliders (brightness/volume, like ASUS Smart Gesture on
  # Windows). Loads uinput and grants the seat user touchpad access; the
  # bindings and user service live in modules/home/laptop.nix.
  services.edgepad.enable = true;

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
