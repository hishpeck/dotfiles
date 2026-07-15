{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    tmux
  ];

  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      resurrect
      # status-right must be set before cpu.tmux loads — it does a find-replace on
      # #{cpu_percentage}/#{ram_percentage} at load time, so the strings must exist first.
      {
        plugin = battery;
        extraConfig = ''
          set -g status-left ""
          set -g status-right ""
          set -ag status-right "#[fg=#{@thm_fg},bg=#{@thm_surface_2}] #{cpu_icon} #{cpu_percentage} "
          set -ag status-right "#[fg=#{@thm_fg},bg=#{@thm_surface_1}] #{ram_icon} #{ram_percentage} "
          set -ag status-right "#{E:@catppuccin_status_date_time}"
        '';
      }
      cpu
    ];

    # Tmux configuration
    extraConfig = ''
      # Enable true color support
      set -g default-terminal "tmux-256color"
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -sa terminal-overrides ",tmux-256color:Tc"
      set -g mouse on

      # Remove escape key delay
      set -s escape-time 0

      # --- KEYMAPS
      ## --- WITHOUT PREFIX
      ### --- Shift arrows to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window
      bind -n S-Up    new-window
      bind -n S-Down  confirm kill-window

      ### --- Alt arrows without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      ## --- WITH PREFIX
      ### --- Vim keys to switch panes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      ## --- CHANGE PREFIX
      unbind C-b
      set -g prefix C-Space
      unbind C-Space
      bind C-Space send-prefix

      # Show project directory name in window title when running nvim
      set -g automatic-rename-format '#{?#{==:#{pane_current_command},nvim},#{b:pane_current_path},#{pane_current_command}}'

      # Set base index for windows and panes
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Theme configuration
      set -g @catppuccin_window_status_style "slanted"

      # Set vi-mode
      set-window-option -g mode-keys vi
      # Keybindings for copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Split window with current path
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };
}
