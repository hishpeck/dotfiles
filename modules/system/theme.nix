{ pkgs, ... }: {
  stylix = {
    enable = true;
    image = ../../wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets = { neovim.enable = false; };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    fonts = {
      sansSerif = {
        package = pkgs.lato;
        name = "Lato";
      };
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
    };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";

    chromium.enable = true;
    lazygit.enable = true;
    btop.enable = true;
    kitty.enable = true;
    tmux.enable = true;
  };
}
