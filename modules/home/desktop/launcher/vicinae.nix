# Vicinae - Raycast-like launcher. Replaced walker (bound in cosmic-config.nix).
#
# Since v0.15.2 vicinae no longer uses layer-shell on COSMIC at all (upstream
# worked around cosmic-comp's strict Wayland protocol validation itself), so
# this doesn't need the useLayerShell/USE_LAYER_SHELL dance older guides
# mention for COSMIC.
{ config, lib, pkgs, osConfig ? null, ... }:
let
  # Same AMD check as cosmic-theme.nix: cosmic-comp's blur flickers on AMD
  # (https://github.com/pop-os/cosmic-comp/issues/2557), so COSMIC's frosted
  # glass is off there and vicinae stays opaque to match.
  isAMD =
    osConfig != null && lib.elem "amdgpu" (osConfig.services.xserver.videoDrivers or [ ]);
in
{
  # Engines for the search-engines extension (~/projects/vicinae-search-engines).
  # The generated JSON is its only source of engines; work.nix / private.nix
  # add their own, and list definitions from every module merge.
  options.programs.vicinae.searchEngines = lib.mkOption {
    type = lib.types.listOf (lib.types.attrsOf lib.types.str);
    default = [ ];
    description = ''
      Search engines: name, prefix, format (google | duckduckgo | opensearch),
      searchUrl and suggestUrl with {query}, or `wiki = "<domain>"` for any
      MediaWiki/Fandom site.
    '';
  };

  config = {
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
      ]
      # Raycast ports, sparse-checked out of raycast/extensions. Each needs its
      # own hash (different sparse tree); work-only ones live in work.nix and
      # pin the same rev — bump both together.
      ++ map (e: config.lib.vicinae.mkRayCastExtension (e // {
        rev = "b3e7c0d11cb48a3246adf3b386c9d1d15ebe0b52";
      })) [
        { name = "1password"; sha256 = "sha256-6md+hO725IM/8NMk599agG4gB3mZufOHFEMnNAxSAfg="; }
        { name = "github"; sha256 = "sha256-j3Hsd+qgieVQicQlNau3zU16t0u/ALSZFWWCbKdeEdM="; }
        { name = "remove-paywall"; sha256 = "sha256-/tOWoyD5wX1chHciy4PGcO9LfXIY3GZvyRYwE0/yK5c="; }
      ]
      # Lives in extensions/google-translate but its package name is
      # "translate", and the helper uses one name for both — so pass src.
      ++ [
        (config.lib.vicinae.mkRayCastExtension {
          name = "translate";
          src = "${pkgs.fetchgit {
            url = "https://github.com/raycast/extensions";
            rev = "b3e7c0d11cb48a3246adf3b386c9d1d15ebe0b52";
            sparseCheckout = [ "/extensions/google-translate" ];
            hash = "sha256-1FiE4KE04/hH1b3YfvQXrLwA5rsnNb221cpAVLuncUU=";
          }}/extensions/google-translate";
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

    # Vicinae can't read COSMIC's frosted setting, but cosmic-comp supports
    # ext-background-effect-v1, so "material": "blur" in settings.json blurs
    # behind the window once opacity < 1. Opacity is per-host, so it lives in
    # this generated file (pulled in via settings.json's "imports") instead of
    # the shared settings.json — and must stay out of settings.json, whose
    # values always win over imported ones.
    xdg.configFile."vicinae/window.json".text = builtins.toJSON {
      launcher_window.opacity = if isAMD then 1 else 0.9;
    };

    programs.vicinae.searchEngines = [
      {
        name = "Google";
        prefix = "g";
        format = "google";
        searchUrl = "https://www.google.com/search?q={query}";
      }
      {
        name = "DuckDuckGo";
        prefix = "ddg";
        format = "duckduckgo";
        searchUrl = "https://duckduckgo.com/?q={query}";
      }
    ];

    xdg.configFile."vicinae/search-engines.json".text =
      builtins.toJSON config.programs.vicinae.searchEngines;
  };
}
