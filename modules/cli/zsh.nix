{ config, pkgs, ... }:

let
  powerlevel10k = pkgs.stdenv.mkDerivation {
    name = "powerlevel10k";
    src = pkgs.fetchFromGitHub {
      owner = "romkatv";
      repo = "powerlevel10k";
      rev = "v1.20.0";
      sha256 = "1ha7qb601mk97lxvcj9dmbypwx7z5v0b7mkqahzsq073f4jnybhi";  # Replace with the correct hash
    };
    installPhase = ''
      mkdir -p $out/share/powerlevel10k
      cp -r $src/* $out/share/powerlevel10k/
    '';
  };
in

{
  home.packages = with pkgs; [
    zsh
    zsh-syntax-highlighting
    zsh-autosuggestions
  ];

  programs.zsh = {
    enable = true;

    # Enable Oh My Zsh and plugins
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "web-search"
        "docker"
        "fzf"
      ];
    };

    # Source Powerlevel10k theme early
    initExtraFirst = ''
    # Source Powerlevel10k theme
    source "${powerlevel10k}/share/powerlevel10k/powerlevel10k.zsh-theme"
    '';

    # Extra Zsh configuration
    initExtra = ''
      # Source Powerlevel10k configuration if it exists
      [[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

      # Enable Powerlevel10k instant prompt
      P10K_INSTANT_PROMPT="$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh"
      [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"

      # Source zsh-syntax-highlighting
      source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

      # Source zsh-autosuggestions
      source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

      # Set oh-my-zsh path
      export ZSH="$HOME/.oh-my-zsh"

      # Set aliases
      alias cfg='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
      alias sail="./vendor/bin/sail"
      alias refresh-tmux="tmux source-file ~/.config/tmux/tmux.conf"
      alias refresh-zsh=". ~/.zshrc"
      alias config-tmux="nvim ~/.config/home-manager/tmux.nix"
      alias config-nvim="nvim ~/.config/nvim"
      alias config-zsh="nvim ~/.config/home-manager/zsh.nix"
      alias config-nix="nvim ~/.config/home-manager"
      alias hms="home-manager switch --flake ~/.config/home-manager#ac-$(uname -m)-linux"
      alias hms-update="z ~/.config/home-manager/ && nix flake update && hms && z -"
      alias docker-compose="docker compose"

      # Custom function using bat for log tailing
      batlog() {
          tail -f "$1" -n 200 | bat --paging=never -l log
      }

      # Set NVM directory and source nvm if it exists
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # Platform.sh CLI configuration
      export PATH="$HOME/.platformsh/bin:$PATH"
      if [ -f "$HOME/.platformsh/shell-config.rc" ]; then
        . "$HOME/.platformsh/shell-config.rc"
      fi

      # bun completions
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"

      # Set PATHs and environment variables
      export PATH="$PATH:/opt/nvim-linux64/bin"
      export PATH="$PATH:$HOME/.local/bin"

      # Set preferred editor
      export VISUAL=nvim
      export EDITOR="$VISUAL"

      export PATH="$HOME/projects/open-source/flutter/bin:$HOME/Android/Sdk/tools:$HOME/Android/Sdk/platform-tools:/usr/local/go/bin:$HOME/.config/composer/vendor/bin:$PATH"

      eval "$(symfony self:completion zsh)"

      source "$HOME/.bash_aliases"
    '';
  };
}
