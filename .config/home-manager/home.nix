{ config, pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./nvim.nix
    ./tmux.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ac";
  home.homeDirectory = "/home/ac";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    git

    unzip
    bat
    lazygit
    lazydocker
    zoxide
    fzf
    btop
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

    go

    uv

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Create a fontconfig configuration file
  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
    <fontconfig>
      <!-- Include the Nix profile fonts directory -->
      <dir>${config.home.profileDirectory}/share/fonts</dir>
    </fontconfig>
  '';

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ac/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    CPATH = "${pkgs.glibc.dev}/include";  
    LIBRARY_PATH = "${pkgs.glibc.dev}/lib";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable zoxide with automatic shell integration
  programs.zoxide.enable = true;

  # fonts.packages = with pkgs; [
  #   (nerdfonts.override { fonts = [ "FiraCode" ]; })
  # ];
}
