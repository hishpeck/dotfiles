{ config, pkgs, lib, inputs, ... }:

{
  home.packages = with pkgs; [
    telegram-desktop
    discord
    steam
    blender
    (pkgs.callPackage ../../custom-apps/freecad/default.nix { })
    (pkgs.callPackage ../../custom-apps/lychee-slicer/default.nix { })
    (pkgs.callPackage ../../custom-apps/uvtools/default.nix { })
    (pkgs.callPackage ../../custom-apps/bambu-studio/default.nix { })
    (pkgs.callPackage ../../custom-apps/patreon-dl-gui/default.nix { })
    fstl
    obsidian
    exiftool
    f3d
    shared-mime-info
    desktop-file-utils
    ncdu
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-cli
    vlc
    atlauncher
  ];

  xdg.desktopEntries.nvim-kitty = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "kitty -e nvim %F";
    terminal = false;
    categories = [ "Utility" "TextEditor" "Development" ];
    mimeType = [
      "text/plain"
      "text/english"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
    ];
  };

  xdg.desktopEntries.fstl = {
    name = "fstl";
    genericName = "Fast STL Viewer";
    comment = "Ultra-fast viewer for 3D STL files";
    exec = "fstl %f"; # The %f tells the file manager to pass the file path
    terminal = false;
    categories = [ "Graphics" "3DGraphics" "Viewer" ];
    mimeType = [
      "model/stl"
      "application/vnd.ms-pki.stl"
      "application/sla"
      "application/x-navistyle"
    ];
  };

  xdg.desktopEntries.lychee-slicer = {
    name = "Lychee Slicer";
    genericName = "3D Slicer";
    comment = "Lychee Slicer for resin 3D printing";
    exec = "lychee-slicer %U";
    terminal = false;
    icon = "lycheeslicer";
    categories = [ "Graphics" "3DGraphics" "Engineering" ];
    mimeType = [
      "application/x-lychee-slicer" # .lys files
      "model/stl"
      "application/vnd.ms-pki.stl"
      "application/sla"
      "application/x-navistyle"
      "x-scheme-handler/lycheeslicer" # OAuth login callback
    ];
  };

  xdg.desktopEntries.bambu-studio = {
    name = "Bambu Studio";
    genericName = "3D Printing Software";
    comment = "A cutting-edge, feature-rich slicing software";
    exec = "bambu-studio %U";
    terminal = false;
    icon = "bambu-studio";
    categories = [ "Graphics" "3DGraphics" "Engineering" ];
    mimeType = [
      "model/stl"
      "model/3mf"
      "application/vnd.ms-pki.stl"
      "application/vnd.ms-3mfdocument"
      "application/prs.wavefront-obj"
      "application/x-amf"
      "application/sla"
      "application/x-navistyle"
      "x-scheme-handler/bambustudio" # MakerWorld "Open in Bambu Studio"
      "x-scheme-handler/bambustudioopen" # MakerWorld "Open in Bambu Studio"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # STL files - fstl is default, but all three listed so handlr selector works
      "model/stl" =
        [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/vnd.ms-pki.stl" =
        [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/sla" =
        [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/x-navistyle" =
        [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];

      # Lychee Slicer files
      "application/x-lychee-slicer" = "lychee-slicer.desktop";

      # Lychee Slicer OAuth login callback
      "x-scheme-handler/lycheeslicer" = "lychee-slicer.desktop";

      # MakerWorld "Open in Bambu Studio"
      "x-scheme-handler/bambustudio" = "bambu-studio.desktop";
      "x-scheme-handler/bambustudioopen" = "bambu-studio.desktop";

      # UVTools files
      "application/x-cxdlpv4" = "uvtools.desktop";

      # Web browser
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "text/html" = "google-chrome.desktop";
      "application/xhtml+xml" = "google-chrome.desktop";

      # PDF
      "application/pdf" = "google-chrome.desktop";
      "application/x-pdf" = "google-chrome.desktop";

      # File manager
      "inode/directory" = "yazi.desktop";

      # Text editor
      "text/plain" = "nvim-kitty.desktop";

      # Music — COSMIC Media Player
      "audio/mpeg" = "com.system76.CosmicPlayer.desktop";
      "audio/ogg" = "com.system76.CosmicPlayer.desktop";
      "audio/flac" = "com.system76.CosmicPlayer.desktop";
      "audio/x-flac" = "com.system76.CosmicPlayer.desktop";
      "audio/wav" = "com.system76.CosmicPlayer.desktop";
      "audio/x-wav" = "com.system76.CosmicPlayer.desktop";
      "audio/aac" = "com.system76.CosmicPlayer.desktop";
      "audio/mp4" = "com.system76.CosmicPlayer.desktop";
      "audio/x-m4a" = "com.system76.CosmicPlayer.desktop";
      "audio/opus" = "com.system76.CosmicPlayer.desktop";
      "audio/x-vorbis+ogg" = "com.system76.CosmicPlayer.desktop";
      "audio/x-opus+ogg" = "com.system76.CosmicPlayer.desktop";
      "audio/webm" = "com.system76.CosmicPlayer.desktop";
      "audio/x-pn-realaudio" = "com.system76.CosmicPlayer.desktop";

      # Video — COSMIC Media Player
      "video/mp4" = "com.system76.CosmicPlayer.desktop";
      "video/x-matroska" = "com.system76.CosmicPlayer.desktop";
      "video/mpeg" = "com.system76.CosmicPlayer.desktop";
      "video/webm" = "com.system76.CosmicPlayer.desktop";
      "video/quicktime" = "com.system76.CosmicPlayer.desktop";
      "video/x-msvideo" = "com.system76.CosmicPlayer.desktop";
      "video/ogg" = "com.system76.CosmicPlayer.desktop";
      "video/x-flv" = "com.system76.CosmicPlayer.desktop";
      "video/x-ms-wmv" = "com.system76.CosmicPlayer.desktop";
      "video/mp2t" = "com.system76.CosmicPlayer.desktop";
      "video/3gpp" = "com.system76.CosmicPlayer.desktop";
      "video/3gpp2" = "com.system76.CosmicPlayer.desktop";
      "video/x-ogm+ogg" = "com.system76.CosmicPlayer.desktop";
      "video/x-theora+ogg" = "com.system76.CosmicPlayer.desktop";
      "video/divx" = "com.system76.CosmicPlayer.desktop";

      # Photos — Noctua
      "image/png" = "org.codeberg.wfx.Noctua.desktop";
      "image/jpeg" = "org.codeberg.wfx.Noctua.desktop";
      "image/gif" = "org.codeberg.wfx.Noctua.desktop";
      "image/webp" = "org.codeberg.wfx.Noctua.desktop";
      "image/bmp" = "org.codeberg.wfx.Noctua.desktop";
      "image/tiff" = "org.codeberg.wfx.Noctua.desktop";
      "image/svg+xml" = "org.codeberg.wfx.Noctua.desktop";
    };

    # Additional associations allow multiple handlers for same file type
    associations.added = {
      "model/stl" =
        [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/vnd.ms-pki.stl" =
        [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/sla" =
        [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/x-navistyle" =
        [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
    };
  };

  xdg.dataFile."thumbnailers/f3d.thumbnailer".text = ''
    [Thumbnailer Entry]
    TryExec=${pkgs.f3d}/bin/f3d
    # Added azimuth (left/right) and elevation (up/down) angles for a 45-degree isometric view
    Exec=sh -c '${pkgs.f3d}/bin/f3d --rendering-backend=egl --camera-azimuth-angle=45 --camera-elevation-angle=45 --verbose=quiet --output="$1" --resolution="$2" "$3"' _ %o %s %i
    MimeType=model/stl;application/sla;model/x.stl-binary;model/x.stl-ascii;
  '';

  # Register .lys file extension for Lychee Slicer
  xdg.dataFile."mime/packages/lychee-slicer.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/x-lychee-slicer">
        <comment>Lychee Slicer Project</comment>
        <glob pattern="*.lys"/>
        <icon name="lycheeslicer"/>
      </mime-type>
    </mime-info>
  '';

  # Register .cxdlpv4 file extension for UVTools (Creality/DLP format)
  xdg.dataFile."mime/packages/uvtools-cxdlpv4.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/x-cxdlpv4">
        <comment>Creality DLP File</comment>
        <glob pattern="*.cxdlpv4"/>
        <icon name="uvtools"/>
      </mime-type>
    </mime-info>
  '';

  # Force MIME database update on activation
  home.activation.updateMimeDatabase =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.shared-mime-info}/bin/update-mime-database $HOME/.local/share/mime
      run ${pkgs.desktop-file-utils}/bin/update-desktop-database $HOME/.local/share/applications
    '';
}
