{ config, pkgs, inputs, ... }:

{
  imports = [ ./zsh.nix ./nvim.nix ./tmux.nix ./yazi.nix ];

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  programs.nix-index-database.comma.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Adrian Castillo";
      user.email = "adr.cas97@gmail.com";
    };
  };

  home.stateVersion = "24.05";

  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  programs.btop = {
    enable = true;
    package = pkgs.btop.override { rocmSupport = true; };
    settings = { theme_background = false; };
  };
  programs.lazygit.enable = true;
  programs.fzf.enable = true;

  home.packages = with pkgs; [
    opencode
    gemini-cli
    gh
    inputs.weave.packages.${pkgs.system}.default

    unzip
    lazydocker
    zoxide

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
  programs.bat.enable = true;

  xdg.configFile = { "mcphub".source = ../../../config/mcphub; };
}
