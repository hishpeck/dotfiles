{ pkgs, ... }: 
let
  flavor = "latte";
in
{
  stylix = {
    enable = true;
    image = ../../wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${flavor}.yaml";
    targets = {
      neovim.enable = false;
      gtk.enable = false;
      yazi.enable = false;
      swaync.enable = false;
      bat.enable = false;
      kitty.enable = false;
      tmux.enable = false;
      fzf.enable = false;
      btop.enable = false;
      kde.enable = false;
      qt.enable = false;
    };

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
    inherit flavor;

    chromium.enable = true;
    lazygit.enable = true;
    btop.enable = true;
    kitty.enable = true;
    tmux.enable = true;
    bat.enable = true;
    fzf.enable = true;
    yazi.enable = true;
  };
}
