{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    # No need to override the package
  };

  # Include development tools in home.packages
  home.packages = with pkgs; [
    wl-clipboard   # Clipboard provider
    gcc            # GNU Compiler Collection
    glibc.dev      # GNU C Library development files
    pkg-config     # Helper tool used during compilation
    fzf            # Fuzzy finder
    ripgrep        # For Telescope.nvim
    # Add other tools if necessary
  ];
}
