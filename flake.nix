{
  description = "Home Manager configuration of ac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cosmix, ... }: {
    nixosConfigurations.zenbook-2022 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nix.settings = {
            substituters = [ "https://cosmic.cachix.org" ];
            trusted-public-keys = [
              "cosmic.cachix.org-1:Dya9IyXD4xdBehWjX81e605KsE0fGjEBrsBv4JNaGVk="
            ];
          };
        }
        nixos-cosmic.nixosModules.default

        ./hosts/zenbook-2022/default.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.ac = {
            imports = [ ./modules/cli ./modules/gui ];
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

