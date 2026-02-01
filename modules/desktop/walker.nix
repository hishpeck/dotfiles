{ inputs, pkgs, config, ... }:

let
  # This grabs the actual hex colors from the catppuccin module
  palette = config.lib.catppuccin.getPalette { };
in {
  programs.walker = {
    enable = true;
    package = inputs.walker.packages.${pkgs.system}.default;

    config = {
      search.placeholder = "Search...";
      ui.width = 400;

      # Activation mode (Raycast style)
      activation_mode.disabled = false;

      # Enable the plugins you want
      plugins = [
        {
          name = "apps";
          placeholder = "Applications";
        }
        {
          name = "emojis";
          placeholder = "Emojis";
          switcher_only = true;
        }
        {
          name = "finder";
          placeholder = "Files";
        }
      ];
    };

    style = ''
      #window {
        background: transparent;
      }
      #box {
        /* We use the 'palette' variable here */
        background: #${palette.base}; 
        border: 2px solid #${palette.mauve};
        border-radius: 15px;
        padding: 16px;
      }
      #search {
        color: #${palette.text};
        background: #${palette.surface0};
        border-radius: 8px;
        padding: 8px;
      }
      #entry:selected {
        background: #${palette.surface1};
      }
      #entry:selected #text {
        color: #${palette.mauve};
      }
    '';
  };

  home.packages = with pkgs; [ wl-clipboard mpv ];
}
