{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
  };

  # Include development tools in home.packages
  home.packages = with pkgs; [
    wl-clipboard   # Clipboard provider
    glibc.dev      # GNU C Library development files
    pkg-config     # Helper tool used during compilation
    fzf            # Fuzzy finder
    ripgrep        # For Telescope.nvim
    sqlite.dev     # For Telescope History
    sqlite
    # Add other tools if necessary
  ];

  home.sessionVariables = {
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim";
}
