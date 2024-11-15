{ config, pkgs, ... }:

let
  # Fetch TPM from GitHub
  tpm = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "v3.1.0";
    sha256 = "18i499hhxly1r2bnqp9wssh0p1v391cxf10aydxaa7mdmrd3vqh9";
  };
  # Fetch the Catppuccin Tmux theme
  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "tmux";
    rev = "v2.1.0";
    sha256 = "1wcabf7j404np9hrimky77yl4a3r3c9ivsl5z5ij29n25lcb2s4i";
  };
in

{
  home.packages = with pkgs; [
    tmux
  ];

  programs.tmux = {
    enable = true;

    # Tmux configuration
    extraConfig = ''
      # Enable true color support and mouse mode
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on

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

      # Set base index for windows and panes
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # TPM plugin list
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'christoomey/vim-tmux-navigator'
      set -g @plugin 'tmux-plugins/tmux-yank'
      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g @plugin 'tmux-plugins/tmux-battery'
      set -g @plugin 'tmux-plugins/tmux-cpu'
      set -g @plugin 'pwittchen/tmux-plugin-ram'
      set -g @plugin 'xamut/tmux-weather'

      # Theme configuration
      set -g @catppuccin_flavor 'latte'
      set -g @catppuccin_window_status_style "slanted"

      # Source the Catppuccin theme from the Nix store
      run-shell '${catppuccin}/catppuccin.tmux'

      set -g status-left ""
      set -g status-right ""
      set -ag status-right "#[fg=#{@thm_crust},bg=#{@thm_rosewater}] #{cpu_icon} #{cpu_percentage} "
      set -ag status-right "#[fg=#{@thm_crust},bg=#{@thm_lavender}] #{ram_icon} #{ram_percentage} "
      set -ag status-right "#{E:@catppuccin_status_date_time}"

      # Set vi-mode
      set-window-option -g mode-keys vi
      # Keybindings for copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Split window with current path
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Initialize TPM (from Nix store)
      run -b '${tpm}/tpm'
    '';
  };
}
