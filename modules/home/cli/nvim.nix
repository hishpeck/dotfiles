{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = ''
      require("hishpeck.core.keymaps")
      require("hishpeck.core.options")
      require("hishpeck.plugins-setup")
    '';

    extraWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [
        pkgs.gcc
        pkgs.gnumake
        pkgs.pkg-config
        pkgs.ripgrep
        pkgs.fd
        pkgs.unzip
        pkgs.wl-clipboard
        pkgs.fzf
      ]}"

      "--prefix"
      "CPATH"
      ":"
      "${pkgs.glibc.dev}/include"
      "--prefix"
      "LIBRARY_PATH"
      ":"
      "${pkgs.glibc.dev}/lib"

      "--set"
      "LIBSQLITE"
      "${pkgs.sqlite.out}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
    ];
  };

  xdg.configFile = {
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/nvim/lua";
    "nvim/after".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/nvim/after";
    "nvim/spell".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/nvim/spell";
    "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/nvim/lazy-lock.json";

    ".vimrc".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/.vimrc";
  };
}
