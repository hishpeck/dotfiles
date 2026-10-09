{ pkgs, options, ... }:
let
  inherit (import ../theme-values.nix) flavor accent;
in
{
  imports = [ ./desktop/cosmic-theme.nix ];
  stylix = {
    enable = true;
    image = ../../wallpapers/autumn.jpg;
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
      vicinae.enable = false;
      rofi.enable = false; # unused; still sets the renamed programs.rofi.font
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
    autoEnable = true;
    inherit flavor accent;

    # Upstream still uses the deprecated `gui.authorColors` key; lazygit tries to
    # migrate it in place and fails on the read-only store path.
    sources.lazygit =
      pkgs.runCommand "catppuccin-lazygit-migrated" { nativeBuildInputs = [ pkgs.yq-go ]; }
        ''
          cp -r ${options.catppuccin.sources.default.lazygit} $out
          chmod -R u+w $out
          for f in $out/*/*.yml; do
            yq -i '.gui.theme.authorColors = .gui.authorColors | del(.gui.authorColors)' "$f"
          done
        '';

    chromium.enable = true;
    lazygit.enable = true;
    btop.enable = true;
    kitty.enable = false;
    nvim.enable = false;
    tmux.enable = true;
    bat.enable = true;
    fzf.enable = true;
    yazi.enable = true;
    zsh-syntax-highlighting.enable = true;
    opencode.enable = true;
  };
}
