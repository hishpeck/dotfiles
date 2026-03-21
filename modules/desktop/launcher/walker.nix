{ inputs, pkgs, config, lib, ... }:
let
  elephantPkg = inputs.elephant.packages.${pkgs.stdenv.hostPlatform.system}.default;

  depsPath = pkgs.lib.makeBinPath [
    elephantPkg
    pkgs.wl-clipboard
    pkgs.mpv
    pkgs.xdg-utils
    pkgs.dbus
    pkgs.wtype
  ];
in {
  programs.walker = {
    enable = true;
    package = inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default;
    runAsService = true;

    config = {
      theme = "default";
      terminal = "kitty";
      placeholders.default = {
        input = "Search...";
        list = "Results";
      };
      ui.width = 400;
      builtins = {
        windows = {
          weight = 100;
          icon = "view-restore";
        };
        applications = { weight = 5; };
        emojis = { exec = "wtype"; };
        websearch.entries = [
          {
            name = "Google";
            url = "https://google.com/search?q=%s";
          }
          {
            name = "DuckDuckGo";
            url = "https://duckduckgo.com/?q=%s";
          }
          {
            name = "NixOS Packages";
            url = "https://search.nixos.org/packages?channel=unstable&query=%s";
          }
          {
            name = "NixOS Options";
            url = "https://search.nixos.org/options?channel=unstable&query=%s";
          }
        ];
      };
      providers.prefixes = [
        {
          provider = "applications";
          prefix = "";
        }
        {
          provider = "websearch";
          prefix = "?";
        }
        {
          provider = "finder";
          prefix = "/";
        }
        {
          provider = "commands";
          prefix = ">";
        }
        {
          provider = "todo";
          prefix = "]";
        }
      ];
    };
  };

  systemd.user.services.walker.Service = {
    Environment = lib.mkForce [
      "PATH=${depsPath}:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"
      "XDG_DATA_DIRS=/etc/profiles/per-user/${config.home.username}/share:/run/current-system/sw/share"
    ];
  };
  systemd.user.services.elephant.Service = {
    Environment = lib.mkForce [
      "PATH=${depsPath}:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"
    ];
  };

  home.packages = [ elephantPkg pkgs.wtype ];
}
