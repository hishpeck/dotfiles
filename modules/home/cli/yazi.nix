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

      # sudo - Call sudo in yazi
      sudo = pkgs.fetchFromGitHub {
        owner = "TD-Sky";
        repo = "sudo.yazi";
        rev = "main";
        sha256 = "sha256-mpQLij+Sg88RarCC+0u7JfZ2EqcX4gB7jvy8bfBt90w=";
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

      table.insert(bookmarks, {
        tag = "Pi5",
        path = home_path .. path_sep .. "Pi5" .. path_sep,
        key = "p"
      })

      table.insert(bookmarks, {
        tag = "USB Media",
        path = path_sep .. "run" .. path_sep .. "media" .. path_sep .. "ac" .. path_sep,
        key = "u"
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

      opener = {
        xdg_default = [{
          run = "${pkgs.handlr-regex}/bin/handlr open %s";
          orphan = true;
          desc = "Handlr (Default)";
        }];
        xdg_interactive = [{
          run = "${pkgs.perlPackages.FileMimeInfo}/bin/mimeopen -d %s";
          block = true;
          desc = "XDG Open With...";
        }];
      };

      open = {
        append_rules = [{
          url = "*";
          use = [ "xdg_default" "xdg_interactive" ];
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
          on = [ "b" "a" ];
          run = "plugin yamb -- save";
          desc = "Add bookmark";
        }
        {
          on = [ "b" "g" ];
          run = "plugin yamb -- jump_by_key";
          desc = "Jump to bookmark by key";
        }
        {
          on = [ "b" "G" ];
          run = "plugin yamb -- jump_by_fzf";
          desc = "Jump to bookmark with fzf";
        }
        {
          on = [ "b" "d" ];
          run = "plugin yamb -- delete_by_key";
          desc = "Delete bookmark by key";
        }
        {
          on = [ "b" "D" ];
          run = "plugin yamb -- delete_by_fzf";
          desc = "Delete bookmark with fzf";
        }
        {
          on = [ "b" "A" ];
          run = "plugin yamb -- delete_all";
          desc = "Delete all bookmarks";
        }
        {
          on = [ "b" "r" ];
          run = "plugin yamb -- rename_by_key";
          desc = "Rename bookmark by key";
        }
        {
          on = [ "b" "R" ];
          run = "plugin yamb -- rename_by_fzf";
          desc = "Rename bookmark with fzf";
        }

        # sudo.yazi plugin - Call sudo in yazi
        {
          on = [ "s" "p" ];
          run = "plugin sudo -- paste";
          desc = "Sudo paste";
        }
        {
          on = [ "s" "P" ];
          run = "plugin sudo -- paste --force";
          desc = "Sudo paste (force)";
        }
        {
          on = [ "s" "r" ];
          run = "plugin sudo -- rename";
          desc = "Sudo rename";
        }
        {
          on = [ "s" "l" ];
          run = "plugin sudo -- link";
          desc = "Sudo link (absolute path)";
        }
        {
          on = [ "s" "L" ];
          run = "plugin sudo -- link --relative";
          desc = "Sudo link (relative path)";
        }
        {
          on = [ "s" "h" ];
          run = "plugin sudo -- hardlink";
          desc = "Sudo hardlink";
        }
        {
          on = [ "s" "a" ];
          run = "plugin sudo -- create";
          desc = "Sudo create (touch/mkdir)";
        }
        {
          on = [ "s" "d" ];
          run = "plugin sudo -- remove";
          desc = "Sudo trash";
        }
        {
          on = [ "s" "D" ];
          run = "plugin sudo -- remove --permanently";
          desc = "Sudo delete permanently";
        }
        {
          on = [ "s" "m" ];
          run = "plugin sudo -- chmod";
          desc = "Sudo chmod";
        }

        # Unmount device (safe removal)
        {
          on = [ "u" "m" ];
          run = ''
            shell 'udisksctl unmount -b "$(df -P "$1" | awk "NR==2 {print \$1}")" && notify-send "Yazi" "Device unmounted successfully"' --confirm'';
          desc = "Unmount current device";
        }

        # Tab navigation
        {
          on = [ "<C-PageUp>" ];
          run = "tab_switch -1 --relative";
          desc = "Switch to previous tab";
        }
        {
          on = [ "<C-PageDown>" ];
          run = "tab_switch 1 --relative";
          desc = "Switch to next tab";
        }

        # Open file with XDG interactive menu (mimeopen)
        {
          on = [ "O" ];
          run = "open --interactive";
          desc = "Open with XDG interactive menu";
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
    nushell # Required for sudo.yazi plugin
    libnotify # For notifications (notify-send)
    perlPackages.FileMimeInfo # Provides mimeopen for interactive file opening
    handlr-regex # For default XDG file opening
  ];
}
