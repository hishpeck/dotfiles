{ pkgs, ... }: {
    stylix = {
        enable = true;
        image = ../../wallpaper.jpg;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";

        cursor = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice"
        };

        fonts = {
          monospace = {
            package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
            name = "FiraCode Nerd Font";
          };
        };
    }
}
