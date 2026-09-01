{ pkgs, lib, inputs, ... }:

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
    inputs.irlume.nixosModules.irlume
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
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "intel_idle.max_cstate=2"
    # Where to find the hibernation image on resume — see the hibernate
    # block below. Offset is only valid for the current swapfile; recompute
    # with `sudo filefrag -v /var/lib/swapfile` if it's ever moved/resized.
    "resume_offset=205115392" # from `filefrag -v`, 2026-08-19; recompute if the swapfile ever moves/resizes
  ];

  # Switching lid-close from suspend to hibernate, 2026-08. Untested
  # reasoning for why this might actually be more reliable than suspend
  # here: suspend/resume keeps the same kernel instance running and tries
  # to reinit the GPU from a suspended state — exactly where the
  # still-unresolved Lunar Lake xe/GuC resume freeze lives (see the
  # ThinkPad X1 Carbon Gen 13 thread investigated 2026-08). Hibernate does
  # a full fresh boot and cold GPU probe on resume instead, which may
  # sidestep that code path entirely — or may not; unconfirmed.
  #
  # Hibernate previously failed outright here: the swapfile (16GiB) was
  # smaller than installed RAM (~30.8GiB), so the hibernation image write
  # ran out of space mid-write (root-caused 2026-08-05). Bumped to 34GiB.
  # NixOS only creates a missing swapfile, it won't resize an existing one
  # in place — the actual on-disk resize has to happen manually first:
  #   sudo swapoff /var/lib/swapfile
  #   sudo fallocate -l 34816M /var/lib/swapfile
  #   sudo mkswap /var/lib/swapfile
  #   sudo swapon /var/lib/swapfile
  #   sudo filefrag -v /var/lib/swapfile | head -n4   # get resume_offset
  swapDevices = lib.mkForce [{
    device = "/var/lib/swapfile";
    size = 34816; # ~34GiB, comfortably above the 31558MiB installed RAM
  }];

  # Root is ext4, not btrfs — resuming from a hibernation image on a swap
  # *file* needs the kernel told which device the filesystem lives on
  # (this) plus the file's physical offset on it (resume_offset above).
  boot.resumeDevice = "/dev/disk/by-uuid/bde83dae-eb2d-4e2a-80d8-77ee274e2bd5";

  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
  };

  # Root cause of the recurring silent hard freezes, found 2026-08-14:
  # xe's __xe_pin_fb_vma_dpt() allocates the display page table from GPU
  # "stolen" memory, which can hang the GT while it's in MC6 (FORCEWAKE
  # stuck, MCA fatal reset, BERT record on next boot, zero kernel trace —
  # matches every crash we've captured). Confirmed by many other Lunar Lake
  # (258V/268V) laptop owners, including another 258V ASUS unit. Was
  # backported via boot.kernelPatches (see git history) until nixpkgs'
  # kernel picked it up; landed upstream in linux-7.2, so the patch is now
  # a no-op (fails to apply) and was removed 2026-08-25.

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

  # The cs35l56 speaker amps (4x, tweeter/woofer L+R) default to 0dB — their
  # absolute max hardware gain — with all volume control left to PipeWire's
  # digital attenuation. That leaves the amps' onboard excursion/thermal
  # protection DSP no headroom, so it clamps audibly ("peaking") on call
  # audio. Cirrus's own kernel maintainer confirms this class of bug
  # upstream: cs35l56 and cs42l43 both default to at/above 0dB max gain,
  # which "can cause distorted audio depending on... other signal-processing
  # elements in the chain" (fixes merged to Mark Brown's sound tree in 6.10
  # and refined again since — see ASoC cs35l56/cs42l43 volume-limit patches).
  # No per-device UCM profile exists for this laptop to set a sane default,
  # so pull all 4 amps down on boot. -12dB (352) killed the peaking but was
  # too quiet overall (needed +150% elsewhere to compensate); -6dB (376,
  # 2026-08-14) is the better tradeoff — still gives the limiter headroom
  # without gutting the volume.
  # Retries until the controls exist since the SoundWire amps enumerate a
  # few seconds into boot, well after this could otherwise run.
  systemd.services.fix-speaker-amp-gain = {
    description = "Pull cs35l56 speaker amp gain down from max for DSP limiter headroom";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "fix-speaker-amp-gain" ''
        amixer="${pkgs.alsa-utils}/bin/amixer"
        for i in $(seq 1 30); do
          if "$amixer" -c0 cget numid=77 >/dev/null 2>&1; then
            for n in 77 81 85 89; do
              "$amixer" -c0 cset numid=$n 376 >/dev/null
            done
            exit 0
          fi
          sleep 1
        done
        echo "amp controls never appeared, giving up" >&2
        exit 1
      '';
    };
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

  # Windows Hello-style face unlock via the dedicated IR camera, 2026-08.
  # Started with howdy (in nixpkgs, simplest to wire up) but swapped for
  # irlume after comparing alternatives: unlike howdy, irlume actually uses
  # the IR-tier hardware for something — TPM-sealed embeddings (AES-256-GCM,
  # not raw images) plus a paired RGB+IR anti-spoof check, versus howdy's
  # complete lack of any anti-spoof gate. Caveat worth remembering: irlume's
  # own docs disclose the IR gate *alone* passes a printed photo 69/70 times
  # in their testing — it's the combination of both models that mitigates
  # this, not IR by itself. Pre-1.0 (v0.11.3), "self-tested against
  # ISO/IEC 30107-3, not lab-certified" per its own README. Not from
  # nixpkgs — pulled in as a flake input (see flake.nix), module imported
  # above.
  #
  # video0 = RGB ("ASUS FHD webcam"), video2 = IR ("ASUS IR camera", index 0
  # capture node — video3 at index 1 is the paired metadata node), both
  # already confirmed working with the stock uvcvideo driver.
  #
  # cosmic-greeter is COSMIC's PAM service (confirmed the only one that
  # exists for this DE — no separate lock-specific PAM file, so this same
  # entry point covers both login and screen unlock). Classified here as
  # "login" profile ([success=1 default=ignore]) since that's the closer
  # match for a full greeter stack; irlume's own "auto" profile detection
  # doesn't have a specific rule for cosmic-greeter's name.
  #
  # polkit-1 and sudo added 2026-09 so 1Password's system-authentication
  # (which goes through polkit, not the GNOME keyring/KDE wallet path that
  # `irlume keyring arm` handles) and sudo itself can also use face auth.
  # Neither is a full greeter or a screen-lock in irlume's own taxonomy —
  # they're one-shot permission prompts, closer in spirit to "lock" (a
  # single sufficient check) than a full login sequence, so that's the
  # profile used for both. Inference, not something the module's docs state
  # explicitly for these two services — if it guesses wrong the likely
  # failure mode is just falling back to password-only for that prompt,
  # not anything breaking.
  services.irlume = {
    enable = true;
    rgbDevice = "/dev/video0";
    irDevice = "/dev/video2";
    pam.services = {
      cosmic-greeter.profile = "login";
      polkit-1.profile = "lock";
      sudo.profile = "lock";
    };
  };

  # Lights the IR emitter LED for reliable detection in irlume above — also
  # re-runs automatically after resume from sleep/hibernate. device already
  # correctly defaults to "video2". Manual one-time steps still required
  # after this applies, in order:
  #   sudo linux-enable-ir-emitter configure   # finds the right command to light the IR LED
  #   sudo irlume enroll --user $USER          # enroll a face
  #   irlume doctor                            # sanity-check the whole setup
  #   sudo irlume keyring arm                  # optional: bind login password to TPM
  services.linux-enable-ir-emitter.enable = true;

  # ISH (Integrated Sensor Hub) firmware fails to load on every boot with
  # the stock linux-firmware blob ("ISH loader: cmd 2 failed 10") — this
  # exact hardware revision needs a different build than the generic
  # ish_lnlm.bin. Community-provided working replacement from the dedicated
  # repo for this laptop:
  # https://github.com/dantmnf/zenbook-s14-ux5406sa-linux (file
  # firmware/intel/ish/ish_lnlm_ef534c00_fb3b8d86.bin). Installed at the
  # exact path the kernel requests (intel/ish/ish_lnlm.bin) with hiPrio so
  # it wins the collision against linux-firmware's own file at that same
  # path when hardware.firmware gets merged into one tree.
  hardware.firmware = [
    (lib.hiPrio (pkgs.runCommand "ish-lnlm-firmware-fix" { } ''
      mkdir -p $out/lib/firmware/intel/ish
      cp ${pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dantmnf/zenbook-s14-ux5406sa-linux/master/firmware/intel/ish/ish_lnlm_ef534c00_fb3b8d86.bin";
        hash = "sha256-AdlQVdGuuy4leUZbR93aOW13t8BIZiyuB5FJpUbky0M=";
      }} $out/lib/firmware/intel/ish/ish_lnlm.bin
    ''))
  ];

  system.stateVersion = "24.05";
}
