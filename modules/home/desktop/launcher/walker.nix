{ inputs, pkgs, config, lib, ... }:
let
  elephantPkg = inputs.elephant.packages.${pkgs.stdenv.hostPlatform.system}.default;

  schemaDir = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

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

  # xdg-desktop-portal-gtk reads GtkSettings (gtk-3.0/settings.ini) and
  # serves it to GTK4 apps via the Settings portal. Writing to gtk-4.0 too
  # as a direct fallback if the portal path doesn't deliver it.
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=Cosmic
  '';
  xdg.configFile."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=Cosmic
  '';
  dconf.settings."org/gnome/desktop/interface".icon-theme = "Cosmic";

  systemd.user.services.walker.Service = {
    Environment = lib.mkForce [
      "PATH=${depsPath}:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"
      "XDG_DATA_DIRS=/etc/profiles/per-user/${config.home.username}/share:/run/current-system/sw/share"
      "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus"
      "GSETTINGS_SCHEMA_DIR=${schemaDir}"
      # COSMIC portal partially handles org.gnome.desktop.interface (only text-scaling-factor),
      # so GTK4 skips settings.ini fallback. no-portals forces it to read settings.ini.
      "GDK_DEBUG=no-portals"
    ];
  };
  systemd.user.services.elephant.Service = {
    Environment = lib.mkForce [
      "PATH=${depsPath}:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"
      "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus"
    ];
  };

  home.packages = [ elephantPkg pkgs.wtype ];
}
