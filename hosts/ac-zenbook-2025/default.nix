{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix/system/intel.nix
    ../../modules/nix/gui/default.nix
    ../../modules/nix/system/default.nix
    ../../modules/nix/system/laptop.nix
    ../../modules/nix/desktop/de/cosmic.nix
    ../../modules/nix/work.nix
    # ../../modules/nix/desktop/wm/hyprland.nix
  ];

  networking.hostName = "ac-zenbook-2025";

  security.pki.certificateFiles = [ ./la.crt ./cnc.crt ];

  # Default suspend was s2idle, which has repeatedly failed to resume and
  # cold-rebooted instead (seen 2026-05-12, 05-22, 06-09, 07-22 — matches
  # "lid opened after a night, looks like it restarted"). Try S3 "deep"
  # sleep instead, which this board also supports (see /sys/power/mem_sleep).
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  # Temporary diagnostics for the recurring hard freezes seen since May 2026
  # (silent, no kernel trace — see 2026-08-05 investigation). No hardware
  # watchdog is exposed on this board (no ACPI WDAT table), so these only
  # help if a future freeze is a detectable soft/hard lockup rather than a
  # total hardware/firmware wedge. Remove once the cause is found.
  boot.kernel.sysctl = {
    "kernel.softlockup_panic" = 1;
    "kernel.hardlockup_panic" = 1;
    "kernel.panic" = 10; # auto-reboot 10s after a captured panic, so pstore/systemd-pstore can surface it next boot
  };

  systemd.services.thermal-logger = {
    description = "Sample CPU temps/fan RPM to disk for freeze diagnostics";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = pkgs.writeShellScript "thermal-logger" ''
        log=/var/log/thermal-history.log
        while true; do
          ts=$(date -Ins)
          {
            for z in /sys/class/thermal/thermal_zone*/; do
              type=$(cat "$z/type" 2>/dev/null)
              temp=$(cat "$z/temp" 2>/dev/null)
              [ -n "$type" ] && echo "$ts zone $type $temp"
            done
            for h in /sys/class/hwmon/hwmon*/; do
              name=$(cat "$h/name" 2>/dev/null)
              case "$name" in
                asus|acpi_fan)
                  for f in "$h"fan*_input; do
                    [ -e "$f" ] && echo "$ts fan $name/$(basename "$f") $(cat "$f")"
                  done
                  ;;
                coretemp)
                  for f in "$h"temp*_input; do
                    [ -e "$f" ] || continue
                    label=$(cat "''${f%_input}_label" 2>/dev/null)
                    echo "$ts temp $name/$label $(cat "$f")"
                  done
                  ;;
              esac
            done
          } >> "$log"
          sync
          sleep 5
        done
      '';
    };
  };

  system.stateVersion = "24.05";
}
