{ pkgs, lib, ... }:
let
  # Catppuccin Latte (official catppuccin/kitty theme values)
  latteColors = {
    foreground = "#4C4F69";
    background = "#EFF1F5";
    selection_foreground = "#EFF1F5";
    selection_background = "#DC8A78";
    cursor = "#DC8A78";
    cursor_text_color = "#EFF1F5";
    url_color = "#DC8A78";
    active_border_color = "#7287FD";
    inactive_border_color = "#9CA0B0";
    bell_border_color = "#DF8E1D";
    active_tab_foreground = "#EFF1F5";
    active_tab_background = "#8839EF";
    inactive_tab_foreground = "#4C4F69";
    inactive_tab_background = "#9CA0B0";
    tab_bar_background = "#BCC0CC";
    mark1_foreground = "#EFF1F5";
    mark1_background = "#7287FD";
    mark2_foreground = "#EFF1F5";
    mark2_background = "#8839EF";
    mark3_foreground = "#EFF1F5";
    mark3_background = "#209FB5";
    color0 = "#5C5F77";
    color8 = "#6C6F85";
    color1 = "#D20F39";
    color9 = "#D20F39";
    color2 = "#40A02B";
    color10 = "#40A02B";
    color3 = "#DF8E1D";
    color11 = "#DF8E1D";
    color4 = "#1E66F5";
    color12 = "#1E66F5";
    color5 = "#EA76CB";
    color13 = "#EA76CB";
    color6 = "#179299";
    color14 = "#179299";
    color7 = "#ACB0BE";
    color15 = "#BCC0CC";
  };

  # Catppuccin Mocha (official catppuccin/kitty theme values)
  mochaColors = {
    foreground = "#CDD6F4";
    background = "#1E1E2E";
    selection_foreground = "#1E1E2E";
    selection_background = "#F5E0DC";
    cursor = "#F5E0DC";
    cursor_text_color = "#1E1E2E";
    url_color = "#F5E0DC";
    active_border_color = "#B4BEFE";
    inactive_border_color = "#6C7086";
    bell_border_color = "#F9E2AF";
    active_tab_foreground = "#11111B";
    active_tab_background = "#CBA6F7";
    inactive_tab_foreground = "#CDD6F4";
    inactive_tab_background = "#181825";
    tab_bar_background = "#11111B";
    mark1_foreground = "#1E1E2E";
    mark1_background = "#B4BEFE";
    mark2_foreground = "#1E1E2E";
    mark2_background = "#CBA6F7";
    mark3_foreground = "#1E1E2E";
    mark3_background = "#74C7EC";
    color0 = "#45475A";
    color8 = "#585B70";
    color1 = "#F38BA8";
    color9 = "#F38BA8";
    color2 = "#A6E3A1";
    color10 = "#A6E3A1";
    color3 = "#F9E2AF";
    color11 = "#F9E2AF";
    color4 = "#89B4FA";
    color12 = "#89B4FA";
    color5 = "#F5C2E7";
    color13 = "#F5C2E7";
    color6 = "#94E2D5";
    color14 = "#94E2D5";
    color7 = "#BAC2DE";
    color15 = "#A6ADC8";
  };

  mkThemeConf = colors: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} ${v}") colors);
in
{
  programs.kitty = {
    enable = true;

    extraConfig = ''
      # Enhanced mouse selection with Shift key
      mouse_map shift+left press ungrabbed mouse_selection normal
      mouse_map shift+left doublepress ungrabbed mouse_selection word
      mouse_map shift+left triplepress ungrabbed mouse_selection line
    '';

    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;

      window_padding_width = 10;
      hide_window_decorations = "yes";
      allow_passthrough = "yes";
      confirm_os_window_close = 0;

      tab_bar_style = "fade";
      tab_bar_show_action_status = "yes";

      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";

      detect_urls = "yes";
      open_url_with = "default";
      copy_on_select = "yes";

      # Allow terminal programs to read/write clipboard
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";

      # Reduce escape key delay for better responsiveness
      repaint_delay = 2;
      input_delay = 2;

      mouse_map = "left click ungrabbed mouse_handle_click selection link prompt";
    };

    keybindings = {
      # Increase font size
      "ctrl+equal" = "change_font_size all +2.0";

      # Decrease font size
      "ctrl+minus" = "change_font_size all -2.0";

      # Reset font size to default
      "ctrl+0" = "change_font_size all 0";
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "no_op";
      "ctrl+shift+enter" = "no_op";
      "ctrl+backspace" = "send_text all \\x17";
      "ctrl+delete" = "send_text all \\e[3;5~";
    };

    shellIntegration.enableZshIntegration = true;
  };

  # Auto-switch kitty's color theme with the OS/COSMIC light-dark preference.
  # kitty queries the OS color scheme itself and hot-swaps already-running
  # windows when these files are present — no watcher/service needed.
  home.file = {
    ".config/kitty/light-theme.auto.conf".text = mkThemeConf latteColors;
    ".config/kitty/dark-theme.auto.conf".text = mkThemeConf mochaColors;
    ".config/kitty/no-preference-theme.auto.conf".text = mkThemeConf latteColors;
  };
}
