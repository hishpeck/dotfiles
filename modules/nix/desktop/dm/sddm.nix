{ pkgs, lib, config, ... }:

{
  services.displayManager.sddm = {
    enable = true;

    # Use Catppuccin theme
    theme = "catppuccin-${config.catppuccin.flavor}";
    package = pkgs.kdePackages.sddm;
    
    # Enable HiDPI support
    enableHidpi = true;
    
    # Wayland support (experimental)
    wayland.enable = true;
    
    # Additional settings
    settings = {
      General = {
        # Display server to use (x11 or wayland)
        DisplayServer = "wayland";
        
        # Input method module
        InputMethod = "";
      };
      
      Theme = {
        # Current theme name
        Current = "catppuccin-${config.catppuccin.flavor}";
        
        # Cursor theme (match with theme.nix - using Bibata-Modern-Ice)
        CursorTheme = "Bibata-Modern-Ice";
        
        # Cursor size
        CursorSize = 24;
        
        # Face icon directory for user avatars
        FacesDir = "/var/lib/AccountsService/icons";
        
        # Theme directory path
        ThemeDir = "/run/current-system/sw/share/sddm/themes";
      };
      
      Users = {
        # Default $PATH
        DefaultPath = "/run/current-system/sw/bin";
        
        # Minimum UID to display in user list
        MinimumUid = 1000;
        
        # Maximum UID to display in user list
        MaximumUid = 60000;
        
        # Users to hide from the user list
        HideUsers = "";
        
        # Shell to execute at login
        HideShells = "";
        
        # Remember last logged in user
        RememberLastUser = true;
        
        # Remember last session
        RememberLastSession = true;
      };
      
      Wayland = {
        # Session command
        SessionCommand = "/run/current-system/sw/bin/dbus-run-session";
        
        # Session directory
        SessionDir = "/run/current-system/sw/share/wayland-sessions";
      };
      
      X11 = {
        # X11 display server command
        DisplayCommand = "/run/current-system/sw/bin/X";
        
        # X11 session directory
        SessionDir = "/run/current-system/sw/share/xsessions";
      };
    };
  };

  # Install the Catppuccin theme with default wallpaper
  environment.systemPackages = with pkgs; [
    (catppuccin-sddm.override {
      flavor = config.catppuccin.flavor;
      font = "Lato";  # Match with theme.nix
      fontSize = "9";
      # Using default Catppuccin SDDM wallpaper (no custom background override)
    })
  ];
}
