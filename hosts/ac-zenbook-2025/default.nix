{ pkgs, lib, ... }:

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

  # Boot-menu entry to run a RAM test — the recurring silent freezes show no
  # software/thermal/lockup signature, so ruling out bad RAM is the next step.
  boot.loader.systemd-boot.memtest86.enable = true;

  # Default suspend was s2idle, which has repeatedly failed to resume and
  # cold-rebooted instead (seen 2026-05-12, 05-22, 06-09, 07-22 — matches
  # "lid opened after a night, looks like it restarted"). Try S3 "deep"
  # sleep instead, which this board also supports (see /sys/power/mem_sleep).
  #
  # The recurring silent hard-freezes (no kernel trace, load/thermal
  # independent) match a known Lunar Lake (Core Ultra 258V) silicon erratum:
  # a MONITOR/MWAIT wakeup can be lost while a core sits in the C3_ACPI idle
  # state (state3 on this board), hanging it with no chance to log anything.
  # Upstream only fixed the kernel's own internal wakeup path
  # (X86_BUG_MONITOR / wake_up_idle_cpu IPI, landed 6.12.5/6.13-rc2) — an
  # external interrupt (e.g. the USB-C dock) waking a core from C3 can still
  # hit the same erratum. Capping cstates below C3 sidesteps it entirely,
  # at the cost of higher idle power draw. 2026-08-14 experiment — see if
  # this eliminates the freezes; loosen back to C3 once confirmed one way
  # or the other.
  boot.kernelParams = [ "mem_sleep_default=deep" "intel_idle.max_cstate=2" ];

  # Root cause of the recurring silent hard freezes, found 2026-08-14:
  # xe's __xe_pin_fb_vma_dpt() allocates the display page table from GPU
  # "stolen" memory, which can hang the GT while it's in MC6 (FORCEWAKE
  # stuck, MCA fatal reset, BERT record on next boot, zero kernel trace —
  # matches every crash we've captured). Confirmed by many other Lunar Lake
  # (258V/268V) laptop owners, including another 258V ASUS unit. Fixed
  # upstream but not yet in any released kernel:
  # https://gitlab.freedesktop.org/drm/xe/kernel/-/commit/a196406a3831291598fe8e73245914f7acffdfe0
  # ("drm/xe: Fix DPT allocation paths.", Maarten Lankhorst, marked for
  # stable v6.12+). Backported here directly since it'll be a while before
  # nixpkgs' kernel picks it up. This forces a from-source kernel build
  # (patched kernel can't use the binary cache) — build on a stronger
  # machine and copy the result over, or substitute via the Nix store.
  #
  # NOTE: the patch was written against a newer xe_fb_pin.c than this
  # kernel may have; if it fails to apply cleanly, it needs a manual
  # rebase (one other Lunar Lake user hit exactly this going from the
  # original patch to their pinned kernel version).
  boot.kernelPatches = [
    {
      name = "xe-fix-dpt-allocation-lunarlake";
      patch = pkgs.fetchpatch {
        url = "https://gitlab.com/freedesktop-mirror/drm-tip/-/commit/a196406a3831291598fe8e73245914f7acffdfe0.patch";
        # Placeholder — first build will fail with a hash mismatch error
        # reporting the correct value; paste it in here.
        hash = lib.fakeHash;
      };
    }
  ];

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
