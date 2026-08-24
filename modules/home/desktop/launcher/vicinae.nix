# Vicinae - Raycast-like launcher. Replaced walker (bound in cosmic-config.nix).
#
# Since v0.15.2 vicinae no longer uses layer-shell on COSMIC at all (upstream
# worked around cosmic-comp's strict Wayland protocol validation itself), so
# this doesn't need the useLayerShell/USE_LAYER_SHELL dance older guides
# mention for COSMIC. Theming is handled by catppuccin/nix's own
# `catppuccin.vicinae` module, which picks up the global flavor/accent from
# theme-values.nix automatically (catppuccin.autoEnable = true).
{ ... }: {
  programs.vicinae = {
    enable = true;
    systemd.enable = true;
  };
}
