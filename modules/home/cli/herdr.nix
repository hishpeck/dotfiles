{ config, pkgs, lib, inputs, ... }:

let
  inherit (config.catppuccin) flavor accent;
  palette = lib.importJSON "${config.catppuccin.sources.palette}/palette.json";
  accentHex = palette.${flavor}.colors.${accent}.hex;
  configPath = "${config.home.homeDirectory}/dotfiles/config/herdr/config.toml";
in
{
  home.packages = [
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Mirrors modules/home/cli/tmux.nix as closely as herdr's config model allows.
  #
  # herdr writes onboarding/settings changes back to config.toml itself, so it
  # needs to stay a real writable file instead of the usual read-only nix
  # store symlink xdg.configFile.text would produce ("failed to save
  # onboarding settings: read only file system"). Symlinked out-of-store to
  # the repo instead, same trick as nvim (cli/nvim.nix) and vicinae
  # (desktop/launcher/vicinae.nix) — edit config/herdr/config.toml by hand or
  # let herdr write to it, both work.
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink configPath;

  # Since the file can't be templated, keep its theme lines in sync with the
  # global catppuccin flavor/accent by patching them in place on every switch.
  home.activation.herdrTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${configPath}" ]; then
      $DRY_RUN_CMD ${pkgs.gnused}/bin/sed -i \
        -e 's/^name = "catppuccin-.*"/name = "catppuccin-${flavor}"/' \
        -e 's/^accent = "#.*"/accent = "${accentHex}"/' \
        "${configPath}"
    fi
  '';
}
