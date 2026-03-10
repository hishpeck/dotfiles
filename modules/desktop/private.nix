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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "model/stl" = "fstl.desktop";
      "application/vnd.ms-pki.stl" = "fstl.desktop";
      "application/sla" = "fstl.desktop";
      "application/x-navistyle" = "fstl.desktop";
      "application/pdf" = "google-chrome.desktop";
      "application/x-pdf" = "google-chrome.desktop";
    };
  };

  xdg.dataFile."thumbnailers/f3d.thumbnailer".text = ''
    [Thumbnailer Entry]
    TryExec=${pkgs.f3d}/bin/f3d
    # Added azimuth (left/right) and elevation (up/down) angles for a 45-degree isometric view
    Exec=sh -c '${pkgs.f3d}/bin/f3d --rendering-backend=egl --camera-azimuth-angle=45 --camera-elevation-angle=45 --verbose=quiet --output="$1" --resolution="$2" "$3"' _ %o %s %i
    MimeType=model/stl;application/sla;model/x.stl-binary;model/x.stl-ascii;
  '';
}

