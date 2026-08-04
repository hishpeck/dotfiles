{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Mirrors modules/home/cli/tmux.nix as closely as herdr's config model allows.
  xdg.configFile."herdr/config.toml".text = ''
    [keys]
    prefix = "ctrl+space"

    # Alt+arrows to move between panes without the prefix (tmux M-Left/Right/Up/Down)
    focus_pane_left = ["prefix+h", "alt+left"]
    focus_pane_down = ["prefix+j", "alt+down"]
    focus_pane_up = ["prefix+k", "alt+up"]
    focus_pane_right = ["prefix+l", "alt+right"]

    # Shift+arrows to move between tabs without the prefix (tmux S-Left/Right/Up/Down)
    previous_tab = ["prefix+p", "shift+left"]
    next_tab = ["prefix+n", "shift+right"]
    new_tab = ["prefix+c", "shift+up"]
    close_tab = ["prefix+shift+x", "shift+down"]

    # Keep tmux's '"' (stacked) / '%' (side by side) split keys alongside herdr's defaults
    split_vertical = ["prefix+v", "prefix+percent"]
    split_horizontal = ["prefix+minus", "prefix+double_quote"]

    [theme]
    name = "catppuccin-latte"

    [theme.custom]
    accent = "#ea76cb"
  '';
}
