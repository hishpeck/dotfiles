{ config, pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./nvim.nix
    ./tmux.nix
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    git

    unzip
    bat
    lazygit
    lazydocker
    zoxide
    fzf
    btop
    yazi
    nerd-fonts.fira-code

    (php84.withExtensions ({ enabled, all }: enabled ++ [
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
    libclang
    openssl
    clang
    glibc.dev
    gnumake
    gcc

    go

    uv
  ];

  home.file = {
  };

  home.sessionVariables = {
    CPATH = "${pkgs.glibc.dev}/include";  
    LIBRARY_PATH = "${pkgs.glibc.dev}/lib";
  };

  programs.home-manager.enable = true;
  programs.zoxide.enable = true;

  xdg.configFile = {
    "mcphub".source = ../../config/mcphub;
    "bat".source = ../../config/bat;
  };
}
