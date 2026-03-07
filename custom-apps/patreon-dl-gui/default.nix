{
  description = "patreon-dl-gui setup for NixOS / Home Manager";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      patreon-dl-gui = pkgs.appimageTools.wrapType2 rec {
        pname = "patreon-dl-gui";
        version = "2.7.1";

        src = pkgs.fetchurl {
          url =
            "https://github.com/patrickkfkan/patreon-dl-gui/releases/download/v${version}/${pname}-${version}-x86_64.AppImage";

          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };

        extraPkgs = pkgs: with pkgs; [ ffmpeg yt-dlp ];
      };

    in {
      packages.${system}.default = patreon-dl-gui;

      homeManagerModules.default = { pkgs, ... }: {
        home.packages = [ patreon-dl-gui pkgs.ffmpeg pkgs.yt-dlp ];
      };
    };
}
