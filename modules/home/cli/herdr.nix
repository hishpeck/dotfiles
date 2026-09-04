{ config, pkgs, inputs, ... }:

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
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/herdr/config.toml";
}
