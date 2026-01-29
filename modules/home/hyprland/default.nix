{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    
    # Tutaj dzieje się magia konfiguracji
    settings = {
      # Zmienna dla mod key (SUPER = Windows Key)
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun";

      # Monitor: auto wykrywanie, wysoka rozdzielczość, skalowanie 1 (możesz zmienić na 1.25 lub 1.5 dla Zenbooka)
      monitor = ",highres,auto,1.5";

      # Wygląd ogólny
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg"; # Te kolory Stylix potem nadpisze!
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Dekoracje okien (zaokrąglenia, blur)
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      # Animacje (domyślne są super)
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # SKRÓTY KLAWISZOWE (Najważniejsze!)
      bind = [
        "$mod, Q, exec, $terminal"        # Super + Q = Terminal
        "$mod, C, killactive,"            # Super + C = Zamknij okno
        "$mod, M, exit,"                  # Super + M = Wyloguj (wyjście z Hyprlanda)
        "$mod, E, exec, dolphin"          # Super + E = Menedżer plików (zmień na yazi/nautilus)
        "$mod, V, togglefloating,"        # Super + V = Pływające okno
        "$mod, R, exec, $menu"            # Super + R = Menu aplikacji (Rofi)
        
        # Przełączanie okien strzałkami
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
      ] ++ (
        # Pętla generująca skróty do workspace'ów 1-9
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, ${toString ws}, workspace, ${toString ws}"
              "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
            ]
          ) 9)
      );

      # Autostart aplikacji
      exec-once = [
        "waybar"           # Pasek
        "dunst"            # Powiadomienia
        "swww init"        # Tapeta
        "nm-applet"        # WiFi w trayu
      ];
    };
  };
  
  # Włączamy Stylix dla Hyprlanda (automatyczne kolory!)
  stylix.targets.hyprland.enable = true;
}
