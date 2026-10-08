{ pkgs, inputs, ... }:

{
  imports = [ inputs.edgepad.homeManagerModules.default ];

  # Lock/turn off the screen after 5 minutes idle. Desktops (ac-main-pc)
  # don't import this and are left unmanaged, i.e. never lock on idle.
  home.file.".config/cosmic/com.system76.CosmicIdle/v1/screen_off_time" = {
    text = "Some(300000)";
    force = true;
  };

  # Replicates ASUS Smart Gesture edge sliders from Windows: slide one finger
  # along the left edge for brightness, right edge for volume. edgepad grabs
  # the touchpad and forwards non-edge input through a virtual one, so the
  # pointer doesn't move while sliding. If input misbehaves:
  #   systemctl --user stop edgepad.service
  services.edgepad = {
    enable = true;
    device = "auto";
    edgeWidth = 8.0e-2;
    sliders = [
      {
        zone = "left";
        up = [ "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%+" ];
        down = [ "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-" ];
      }
      {
        zone = "right";
        up = [ "${pkgs.pamixer}/bin/pamixer" "-i" "3" ];
        down = [ "${pkgs.pamixer}/bin/pamixer" "-d" "3" ];
      }
    ];
  };
}
