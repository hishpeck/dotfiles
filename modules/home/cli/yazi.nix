{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";

    # Enable shell integrations
    enableZshIntegration = true;

    # Use packaged plugins from nixpkgs
    plugins = {
      inherit (pkgs.yaziPlugins) git chmod smart-enter relative-motions piper;

      # yamb (Yet another bookmarks) - manually fetched
      yamb = pkgs.fetchFromGitHub {
        owner = "h-hg";
        repo = "yamb.yazi";
        rev = "main";
        sha256 = "sha256-3Cp3+v0laSVsDdTyG26EOh2xt18ER8P9Nla9vtRuj9k=";
      };
    };

    # Initialize plugins
    initLua = ''
      -- Setup relative-motions plugin
      require("relative-motions"):setup({ 
        show_numbers = "relative_absolute",
        show_motion = true 
      })

      -- Setup yamb (Yet another bookmarks) plugin
      local bookmarks = {}
      local path_sep = package.config:sub(1, 1)
      local home_path = os.getenv("HOME")

      table.insert(bookmarks, {
        tag = "Desktop",
        path = home_path .. path_sep .. "Desktop" .. path_sep,
        key = "d"
      })

      require("yamb"):setup({
        bookmarks = bookmarks,
        jump_notify = true,
        cli = "fzf",
        keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        path = home_path .. "/.config/yazi/bookmark",
      })
    '';

    settings = {
      manager = {
        show_hidden = true;
        ratio = [ 1 4 3 ];
      };

      plugin = {
        prepend_fetchers = [{
          id = "git";
          name = "*";
          run = "git";
        }];
        prepend_previewers = [{
          name = "*.md";
          run = "piper";
        }];
      };
    };

    # Keybindings (Using the correct Yazi 0.3+ argument syntax)
    keymap = {
      mgr.prepend_keymap = [
        # relative-motions number keybindings
        {
          on = [ "1" ];
          run = "plugin relative-motions 1";
          desc = "Move in relative steps";
        }
        {
          on = [ "2" ];
          run = "plugin relative-motions 2";
          desc = "Move in relative steps";
        }
        {
          on = [ "3" ];
          run = "plugin relative-motions 3";
          desc = "Move in relative steps";
        }
        {
          on = [ "4" ];
          run = "plugin relative-motions 4";
          desc = "Move in relative steps";
        }
        {
          on = [ "5" ];
          run = "plugin relative-motions 5";
          desc = "Move in relative steps";
        }
        {
          on = [ "6" ];
          run = "plugin relative-motions 6";
          desc = "Move in relative steps";
        }
        {
          on = [ "7" ];
          run = "plugin relative-motions 7";
          desc = "Move in relative steps";
        }
        {
          on = [ "8" ];
          run = "plugin relative-motions 8";
          desc = "Move in relative steps";
        }
        {
          on = [ "9" ];
          run = "plugin relative-motions 9";
          desc = "Move in relative steps";
        }

        # Built-in integrations (no explicit plugin package needed)
        {
          on = [ "z" ];
          run = "plugin zoxide";
          desc = "Jump to a directory using zoxide";
        }
        {
          on = [ "f" ];
          run = "plugin fzf";
          desc = "Jump to a file using fzf";
        }
        {
          on = [ "S" ];
          run = "plugin rg";
          desc = "Search files by content using ripgrep";
        }

        # Third-party plugins
        {
          on = [ "l" ];
          run = "plugin smart-enter";
          desc = "Smart enter: open files or enter directories";
        }
        {
          on = [ "c" "m" ];
          run = "plugin chmod";
          desc = "Change file permissions";
        }

        # yamb (Yet another bookmarks) plugin
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
        {
          on = [ "u" "A" ];
          run = "plugin yamb -- delete_all";
          desc = "Delete all bookmarks";
        }
        {
          on = [ "u" "r" ];
          run = "plugin yamb -- rename_by_key";
          desc = "Rename bookmark by key";
        }
        {
          on = [ "u" "R" ];
          run = "plugin yamb -- rename_by_fzf";
          desc = "Rename bookmark with fzf";
        }
      ];
    };
  };

  # Yazi dependencies
  home.packages = with pkgs; [
    file # Required for file type detection
    glow # Required for markdown preview
    zoxide # For zoxide plugin
    fzf # For fzf plugin
    ripgrep # For ripgrep plugin
  ];
}
