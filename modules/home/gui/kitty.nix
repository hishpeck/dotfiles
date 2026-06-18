{ pkgs, ... }:
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
      # Catppuccin Latte
      foreground            = "#4C4F69";
      background            = "#EFF1F5";
      selection_foreground  = "#EFF1F5";
      selection_background  = "#DC8A78";
      cursor                = "#DC8A78";
      cursor_text_color     = "#EFF1F5";
      url_color             = "#DC8A78";
      active_border_color   = "#7287FD";
      inactive_border_color = "#9CA0B0";
      bell_border_color     = "#DF8E1D";
      active_tab_foreground   = "#EFF1F5";
      active_tab_background   = "#8839EF";
      inactive_tab_foreground = "#4C4F69";
      inactive_tab_background = "#9CA0B0";
      tab_bar_background      = "#BCC0CC";
      mark1_foreground = "#EFF1F5";
      mark1_background = "#7287FD";
      mark2_foreground = "#EFF1F5";
      mark2_background = "#8839EF";
      mark3_foreground = "#EFF1F5";
      mark3_background = "#209FB5";
      color0  = "#5C5F77"; color8  = "#6C6F85";
      color1  = "#D20F39"; color9  = "#D20F39";
      color2  = "#40A02B"; color10 = "#40A02B";
      color3  = "#DF8E1D"; color11 = "#DF8E1D";
      color4  = "#1E66F5"; color12 = "#1E66F5";
      color5  = "#EA76CB"; color13 = "#EA76CB";
      color6  = "#179299"; color14 = "#179299";
      color7  = "#ACB0BE"; color15 = "#BCC0CC";

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
}
