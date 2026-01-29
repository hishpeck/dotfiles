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
      config-tmux = "nvim ~/dotfiles/modules/cli/tmux.nix";
      config-nvim = "nvim ~/dotfiles/config/nvim";
      config-zsh = "nvim ~/dotfiles/modules/cli/zsh.nix";
      config-nix = "nvim ~/dotfiles";
      hms = "home-manager switch --flake ~/dotfiles#ac-$(uname -m)-linux";
      hms-update = "cd ~/dotfiles && nix flake update && hms && cd -";
      nix-update = "sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)";
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

        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        if [ -f "$HOME/.platformsh/shell-config.rc" ]; then
          . "$HOME/.platformsh/shell-config.rc"
        fi

        eval "$(symfony self:completion zsh)"
      ''
    ];
  };
}
