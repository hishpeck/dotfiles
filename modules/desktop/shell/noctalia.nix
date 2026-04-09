{ pkgs, lib, config, inputs, ... }:

# Noctalia - A sleek and minimal desktop shell for Wayland
# Configured to match the Catppuccin Latte theme from theme.nix

let
  flavor = "latte";  # Match flavor from theme.nix
in
{
  # To use this module, add to your flake.nix inputs:
  # noctalia = {
  #   url = "github:noctalia-dev/noctalia-shell";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };
  #
  # Then import in your home-manager configuration:
  # imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    
    settings = {
      # Bar configuration
      bar = {
        position = "top";
        density = "default";
        showCapsule = true;
        capsuleOpacity = 1;
        backgroundOpacity = 0.93;
        marginVertical = 4;
        marginHorizontal = 4;
        
        widgets = {
          left = [
            {
              id = "Launcher";
            }
            {
              id = "ActiveWindow";
            }
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "none";
            }
          ];
          right = [
            {
              id = "SystemMonitor";
            }
            {
              id = "Tray";
            }
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "Volume";
            }
            {
              id = "Battery";
              warningThreshold = 30;
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              useMonospacedFont = false;
            }
            {
              id = "ControlCenter";
              useDistroLogo = false;
            }
          ];
        };
      };

      # General settings
      general = {
        avatarImage = "";  # Set to your avatar path if desired
        radiusRatio = 0.2;
        scaleRatio = 1;
        animationSpeed = 1;
        enableShadows = true;
        enableBlurBehind = true;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
      };

      # UI settings - match Lato font from theme.nix
      ui = {
        fontDefault = "Lato";
        fontFixed = "FiraCode Nerd Font";
        fontDefaultScale = 1;
        fontFixedScale = 1;
        tooltipsEnabled = true;
        panelBackgroundOpacity = 0.93;
      };

      # Location/Weather settings
      location = {
        name = "Tokyo";  # Change to your location
        weatherEnabled = true;
        useFahrenheit = false;
        use12hourFormat = false;
        showWeekNumberInCalendar = false;
        showCalendarEvents = true;
      };

      # App Launcher configuration - integrate with your existing walker
      appLauncher = {
        position = "center";
        sortByMostUsed = true;
        terminalCommand = "kitty -e";  # Use kitty from your config
        viewMode = "list";
        showCategories = true;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        enableClipboardHistory = true;
        autoPasteClipboard = false;
      };

      # Control Center
      controlCenter = {
        position = "close_to_bar_button";
        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "Bluetooth"; }
            { id = "WallpaperSelector"; }
            { id = "NoctaliaPerformance"; }
          ];
          right = [
            { id = "Notifications"; }
            { id = "PowerProfile"; }
            { id = "KeepAwake"; }
            { id = "NightLight"; }
          ];
        };
      };

      # Notifications
      notifications = {
        enabled = true;
        location = "top_right";
        density = "default";
        backgroundOpacity = 1;
        normalUrgencyDuration = 8;
        criticalUrgencyDuration = 15;
        enableMediaToast = true;
        enableKeyboardLayoutToast = true;
        enableBatteryToast = true;
      };

      # Audio settings - match with your audio step preferences
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        visualizerType = "linear";
        volumeFeedback = false;
      };

      # Brightness control
      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
      };

      # Color scheme - use wallpaper colors or set custom Catppuccin colors below
      colorSchemes = {
        useWallpaperColors = true;  # Extract colors from wallpaper.png
        darkMode = false;  # Latte is a light theme
        schedulingMode = "off";
        syncGsettings = true;
        generationMethod = "tonal-spot";
      };

      # Wallpaper integration
      wallpaper = {
        enabled = true;
        fillMode = "crop";
        automationEnabled = false;
        panelPosition = "follow_bar";
      };

      # Session menu
      sessionMenu = {
        enableCountdown = true;
        countdownDuration = 10000;
        position = "center";
        showHeader = true;
        showKeybinds = true;
      };

      # Night light (disabled by default, matching your theme setup)
      nightLight = {
        enabled = false;
        autoSchedule = true;
      };

      # System monitor thresholds
      systemMonitor = {
        cpuWarningThreshold = 80;
        cpuCriticalThreshold = 90;
        memWarningThreshold = 80;
        memCriticalThreshold = 90;
        batteryWarningThreshold = 20;
        batteryCriticalThreshold = 5;
      };
    };

    # Catppuccin Latte colors matching your theme
    # These are the Material 3 color values for Catppuccin Latte
    colors = {
      mPrimary = "#1e66f5";        # Blue
      mOnPrimary = "#ffffff";      # White
      mSecondary = "#8839ef";      # Mauve
      mOnSecondary = "#ffffff";    # White
      mTertiary = "#ea76cb";       # Pink
      mOnTertiary = "#ffffff";     # White
      mError = "#d20f39";          # Red
      mOnError = "#ffffff";        # White
      mSurface = "#eff1f5";        # Base (light background)
      mOnSurface = "#4c4f69";      # Text (dark text)
      mSurfaceVariant = "#e6e9ef";  # Mantle
      mOnSurfaceVariant = "#5c5f77"; # Subtext0
      mOutline = "#9ca0b0";        # Overlay0
      mShadow = "#000000";         # Black
      mHover = "#dce0e8";          # Crust (hover state)
      mOnHover = "#4c4f69";        # Text on hover
    };
  };

  # Additional packages for Noctalia desktop shell
  home.packages = with pkgs; [
    # Clipboard manager for Noctalia
    cliphist
    wl-clipboard
    
    # Screenshot tools
    grim
    slurp
    swappy
    
    # Network manager
    networkmanagerapplet
  ];
}
