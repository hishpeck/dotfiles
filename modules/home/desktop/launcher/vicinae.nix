# Vicinae - Raycast-like launcher. Replaced walker (bound in cosmic-config.nix).
#
# Since v0.15.2 vicinae no longer uses layer-shell on COSMIC at all (upstream
# worked around cosmic-comp's strict Wayland protocol validation itself), so
# this doesn't need the useLayerShell/USE_LAYER_SHELL dance older guides
# mention for COSMIC.
{ config, lib, pkgs, ... }: {
  programs.vicinae = {
    enable = true;
    systemd.enable = true;

    # Declared here instead of installed through the in-app store so every
    # machine gets the same extensions — the store writes straight into
    # ~/.local/share/vicinae/extensions, a plain per-machine directory Nix
    # never sees otherwise.
    extensions = [
      (config.lib.vicinae.mkExtension {
        name = "nix";
        src = "${pkgs.fetchFromGitHub {
          owner = "knoopx";
          repo = "vicinae-extensions";
          rev = "152d5233ec8ddf9bab1c1bd9a2c08f21fe40d24a";
          hash = "sha256-JCnz2lGgBNrXgTVBD8ztS0BBHbUqBk6wyE089+ySNhw=";
        }}/extensions/nix";
      })
    ];
  };

  # Vicinae writes GUI-driven changes (theme picks, preferences, etc.) back to
  # settings.json, so it needs to stay a real writable file — not the usual
  # read-only nix store symlink `xdg.configFile`/`programs.vicinae.settings`
  # would produce (see docs.vicinae.com/faq "How to deal with read-only
  # configuration?"). Symlinked out-of-store to the repo instead, same trick
  # as the nvim config in cli/nvim.nix, so it's editable both by hand and by
  # vicinae itself. This replaces catppuccin.vicinae's generated settings.json
  # (hence mkForce) — its theme *file* generation in
  # ~/.local/share/vicinae/themes is untouched and still declarative; only the
  # "which theme is selected" line in settings.json is now manual — update
  # config/vicinae/settings.json by hand if the global flavor/accent changes.
  xdg.configFile."vicinae/settings.json".source = lib.mkForce
    (config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/config/vicinae/settings.json");
}
