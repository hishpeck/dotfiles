{ config, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";

    # Enable shell integrations
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;

    # Initialize plugins that need setup
    initLua = ''
      -- Setup relative-motions plugin
      require("relative-motions"):setup({ 
        show_numbers = "relative_absolute",
        show_motion = true 
      })
      
      -- Setup yamb (bookmarks) plugin
      require("yamb"):setup({
        bookmarks = {},
        jump_notify = true,
        cli = "fzf",
      })
    '';

    plugins = {
      "f3d-preview" = pkgs.fetchFromGitHub {
        owner = "ruudjhuu";
        repo = "f3d-preview.yazi";
        rev = "76d115d";
        hash = "sha256-katk13VE8J/Gn7N2Ez30/Xq0ldBV3yP2kowA0qVWYEg=";
      };
      "git" = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "196281844b8cbcac658a59013e4805300c2d6126";
        hash = "sha256-pAkBlodci4Yf+CTjhGuNtgLOTMNquty7xP0/HSeoLzE=";
      } + "/git.yazi";
      "smart-enter" = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "196281844b8cbcac658a59013e4805300c2d6126";
        hash = "sha256-pAkBlodci4Yf+CTjhGuNtgLOTMNquty7xP0/HSeoLzE=";
      } + "/smart-enter.yazi";
      "chmod" = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "196281844b8cbcac658a59013e4805300c2d6126";
        hash = "sha256-pAkBlodci4Yf+CTjhGuNtgLOTMNquty7xP0/HSeoLzE=";
      } + "/chmod.yazi";
      "relative-motions" = pkgs.fetchFromGitHub {
        owner = "dedukun";
        repo = "relative-motions.yazi";
        rev = "a603d9ea924dfc0610bcf9d3129e7cba605d4501";
        hash = "sha256-9i6x/VxGOA3bB3FPieB7mQ1zGaMK5wnMhYqsq4CvaM4=";
      };
      "yamb" = pkgs.fetchFromGitHub {
        owner = "h-hg";
        repo = "yamb.yazi";
        rev = "5f2e22e784dd5fc830cd85885a6d1d6690b52298";
        hash = "sha256-3Cp3+v0laSVsDdTyG26EOh2xt18ER8P9Nla9vtRuj9k=";
      };
      "bypass" = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "bypass.yazi";
        rev = "c1e5fcf6eeed0bfceb57b9738da6db9d0fb8af56";
        hash = "sha256-ZndDtTMkEwuIMXG4SGe4B95Nw4fChfFhxJHj+IY30Kc=";
      };
      "piper" = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "196281844b8cbcac658a59013e4805300c2d6126";
        hash = "sha256-pAkBlodci4Yf+CTjhGuNtgLOTMNquty7xP0/HSeoLzE=";
      } + "/piper.yazi";
    };

    settings = {
      plugin = {
        prepend_preloaders = [{
          name = "*.{3mf,obj,pts,ply,stl,step,stp}";
          run = "f3d-preview";
        }];
        prepend_previewers = [
          {
            name = "*.{3mf,obj,pts,ply,stl,step,stp}";
            run = "f3d-preview";
          }
          {
            name = "*.md";
            run = "piper";
          }
        ];
        prepend_fetchers = [{
          id = "git";
          name = "*";
          run = "git";
        }];
      };

      # Use fd for faster file searching
      manager = {
        show_hidden = true;
        ratio = [ 1 4 3 ];
      };

      # Use ripgrep for content searching
      opener = {
        edit = [{
          run = ''$EDITOR "$@"'';
          block = true;
        }];
      };
    };

    # Keybindings for integrations
    keymap = {
      manager.prepend_keymap = [
        # TEST: Bind to a definitely unused key to verify plugin works
        {
          on = [ "<C-n>" ];
          run = "plugin relative-motions";
          desc = "Start relative motion (Ctrl+n, then number+direction)";
        }
        # relative-motions - Alternative trigger to test if plugin works
        {
          on = [ "V" ];
          run = "plugin relative-motions";
          desc = "Start a relative motion (then type number + direction)";
        }
        # relative-motions - number triggers for vim-style motions
        {
          on = [ "1" ];
          run = "plugin relative-motions --args=1";
          desc = "Move in relative steps";
        }
        {
          on = [ "2" ];
          run = "plugin relative-motions --args=2";
          desc = "Move in relative steps";
        }
        {
          on = [ "3" ];
          run = "plugin relative-motions --args=3";
          desc = "Move in relative steps";
        }
        {
          on = [ "4" ];
          run = "plugin relative-motions --args=4";
          desc = "Move in relative steps";
        }
        {
          on = [ "5" ];
          run = "plugin relative-motions --args=5";
          desc = "Move in relative steps";
        }
        {
          on = [ "6" ];
          run = "plugin relative-motions --args=6";
          desc = "Move in relative steps";
        }
        {
          on = [ "7" ];
          run = "plugin relative-motions --args=7";
          desc = "Move in relative steps";
        }
        {
          on = [ "8" ];
          run = "plugin relative-motions --args=8";
          desc = "Move in relative steps";
        }
        {
          on = [ "9" ];
          run = "plugin relative-motions --args=9";
          desc = "Move in relative steps";
        }
        # zoxide integration - jump to frecent directories
        {
          on = [ "z" ];
          run = "plugin zoxide";
          desc = "Jump to a directory using zoxide";
        }
        # fzf integration - fuzzy find files
        {
          on = [ "f" ];
          run = "plugin fzf";
          desc = "Jump to a file using fzf";
        }
        # ripgrep search
        {
          on = [ "S" ];
          run = "plugin rg";
          desc = "Search files by content using ripgrep";
        }
        # smart-enter - open files or enter directories
        {
          on = [ "l" ];
          run = "plugin smart-enter";
          desc = "Smart enter: open files or enter directories";
        }
        # chmod - change file permissions
        {
          on = [ "c" "m" ];
          run = "plugin chmod";
          desc = "Change file permissions";
        }
        # yamb - bookmarks manager (use 'u' as prefix to avoid conflicts)
        {
          on = [ "u" "a" ];
          run = "plugin yamb -- save";
          desc = "Add bookmark";
        }
        {
          on = [ "u" "g" ];
          run = "plugin yamb -- jump_by_key";
          desc = "Jump to bookmark by key";
        }
        {
          on = [ "u" "G" ];
          run = "plugin yamb -- jump_by_fzf";
          desc = "Jump to bookmark with fzf";
        }
        {
          on = [ "u" "d" ];
          run = "plugin yamb -- delete_by_key";
          desc = "Delete bookmark by key";
        }
        {
          on = [ "u" "D" ];
          run = "plugin yamb -- delete_by_fzf";
          desc = "Delete bookmark with fzf";
        }
        # bypass - smart archive extraction/creation
        {
          on = [ "x" ];
          run = "plugin bypass";
          desc = "Extract or create archive";
        }
      ];
    };
  };

  # Yazi dependencies
  home.packages = with pkgs; [
    file # Required for file type detection
    glow # Required for piper markdown preview
    f3d # Required for 3D model preview
  ];
}
