{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "web-search" "docker" "fzf" ];
    };

    shellAliases = {
      cfg = "/usr/bin/git --work-tree=$HOME/dotfiles/";
      sail = "./vendor/bin/sail";
      refresh-tmux = "tmux source-file ~/.config/tmux/tmux.conf";
      refresh-zsh = ". ~/.zshrc";
      config-tmux = "nvim ~/dotfiles/modules/home/cli/tmux.nix";
      config-nvim = "nvim ~/dotfiles/config/nvim";
      config-zsh = "nvim ~/dotfiles/modules/home/cli/zsh.nix";
      nico = "nvim ~/dotfiles";
      hms = "nh home switch ~/dotfiles";
      hms-update = "nh home switch --update ~/dotfiles";
      niup = "nh os switch --update ~/dotfiles";
      nipu =
        "nix path-info --recursive /run/current-system | cachix push hishpeck";
      docker-compose = "docker compose";
      lagi = "lazygit";
      lado = "lazydocker";
    };

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

        batlog() {
            tail -f "$1" -n 200 | bat --paging=never -l log
        }

        nvim() {
            if [ -f ~/.env ]; then
                env $(grep -v '^#' ~/.env | xargs) nvim "$@"
            else
                command nvim "$@"
            fi
        }

        if [[ "$TERM" == "xterm-kitty" ]]; then
            alias ssh="kitty +kitten ssh"
        fi

          # Image preview function that checks if we are in Kitty
        icat() {
            if [[ "$TERM" == "xterm-kitty" ]]; then
                kitty +kitten icat "$@"
            else
                echo "Not in Kitty terminal; image preview unavailable."
            fi
        }

        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        if [ -f "$HOME/.platformsh/shell-config.rc" ]; then
          . "$HOME/.platformsh/shell-config.rc"
        fi

        eval "$(symfony self:completion zsh)"

        bindkey "^W" backward-kill-word
        bindkey "\e[3;5~" kill-word
      ''
    ];
  };
}
