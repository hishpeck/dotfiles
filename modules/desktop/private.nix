{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    telegram-desktop
    discord
    steam
    blender
    freecad
    (pkgs.callPackage ../../custom-apps/lychee-slicer/default.nix { })
    (pkgs.callPackage ../../custom-apps/uvtools/default.nix { })
    (pkgs.callPackage ../../custom-apps/bambu-studio/default.nix { })
    (pkgs.callPackage ../../custom-apps/patreon-dl-gui/default.nix { })
    fstl
    obsidian
    exiftool
    f3d
    shared-mime-info
  ];

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
    exec = "lychee-slicer --no-sandbox %U";
    terminal = false;
    icon = "lycheeslicer";
    categories = [ "Graphics" "3DGraphics" "Engineering" ];
    mimeType = [
      "application/x-lychee-slicer"  # .lys files
      "model/stl"
      "application/vnd.ms-pki.stl"
      "application/sla"
      "application/x-navistyle"
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
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # STL files - fstl is default for quick preview
      "model/stl" = "fstl.desktop";
      "application/vnd.ms-pki.stl" = "fstl.desktop";
      "application/sla" = "fstl.desktop";
      "application/x-navistyle" = "fstl.desktop";
      
      # Lychee Slicer files
      "application/x-lychee-slicer" = "lychee-slicer.desktop";
      
      # PDF
      "application/pdf" = "google-chrome.desktop";
      "application/x-pdf" = "google-chrome.desktop";
    };
    
    # Additional associations allow multiple handlers for same file type
    associations.added = {
      "model/stl" = [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/vnd.ms-pki.stl" = [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/sla" = [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
      "application/x-navistyle" = [ "fstl.desktop" "lychee-slicer.desktop" "bambu-studio.desktop" ];
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
}

