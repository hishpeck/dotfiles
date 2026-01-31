{ config, pkgs, ... }:

{
  imports = [ ./zsh.nix ./nvim.nix ./tmux.nix ];

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Adrian Castillo";
      user.email = "adr.cas97@gmail.com";
    };
  };

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    unzip
    bat
    lazygit
    lazydocker
    zoxide
    fzf
    btop
    yazi
    nerd-fonts.fira-code

    (php84.withExtensions ({ enabled, all }:
      enabled ++ [
        all.amqp
        all.xsl
        all.redis
        all.mbstring
        all.pdo_pgsql
        all.iconv
        all.memcached
      ]))
    php84Packages.composer
    symfony-cli

    mariadb
    postgresql

    nodejs_latest

    rustup
    openssl
    glibc.dev
    gnumake
    gcc

    go

    uv
  ];

  home.file = { };

  
  programs.zoxide.enable = true;

  xdg.configFile = {
    "mcphub".source = ../../../config/mcphub;
    "bat".source = ../../../config/bat;
  };
}
