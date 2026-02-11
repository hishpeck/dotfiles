{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;

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
    };

    shellIntegration.enableZshIntegration = true;
  };
}
