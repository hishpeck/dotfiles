{
  description = "Home Manager configuration of ac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }: {
    nixosConfigurations.ac-zenbook-2022 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/ac-zenbook-2022/default.nix
        ./modules/gui/default.nix
        stylix.nixosModules.stylix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.ac = {
            imports = [ ./modules/cli ];
          };
        }
      ];
    };
    homeConfigurations = {
      "ac-x86_64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          ./modules/cli/default.nix
          {
            home.username = "ac";
            home.homeDirectory = "/home/ac";
          }
        ];
      };

      "ac-aarch64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-linux";
        modules = [
          ./modules/cli/default.nix
          {
            home.username = "ac";
            home.homeDirectory = "/home/ac";
          }
        ];
      };
    };
  };
}

