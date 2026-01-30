{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [ wl-clipboard fzf ripgrep fd unzip ];

    extraWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [ pkgs.gcc pkgs.gnumake pkgs.pkg-config ]}"

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

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/config/nvim";

  xdg.configFile.".vimrc".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/config/.vimrc";
}
