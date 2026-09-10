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

  # secrets.json is a plain, un-managed file living outside both the Nix
  # store and the dotfiles repo — create it by hand once per machine (see
  # config/vicinae/README.md) and never through the GUI, since anything typed
  # into an extension's own preferences form gets written straight into the
  # git-tracked settings.json instead. Values in here take precedence over
  # settings.json for whatever keys they set (vicinae merges override files
  # last), so this is the one place secrets belong.
  #
  # No `programs.vicinae.systemd.environment` option exists in this (the
  # nixpkgs-native) home-manager module, so this is added directly to the
  # unit it generates instead — it doesn't set Service.Environment itself,
  # so there's nothing to conflict with.
  systemd.user.services.vicinae.Service.Environment =
    [ "VICINAE_OVERRIDES=${config.home.homeDirectory}/.config/vicinae/secrets.json" ];

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
