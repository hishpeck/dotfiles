{
  description = "Universal Config for ac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs:
    let
      user = "ac";

      mkNixOS = host: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs user; };
          modules = [
            ./hosts/${host}/default.nix

            stylix.nixosModules.stylix

            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user; };
              home-manager.backupFileExtension = "backup";

              home-manager.sharedModules = [ stylix.homeModules.stylix ];

              home-manager.users.${user} = import ./hosts/${host}/home.nix;
            }
          ];
        };

      mkHome = host: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs user; };
          modules = [
            ./hosts/${host}/default.nix

            stylix.homeModules.stylix

            {
              home.username = user;
              home.homeDirectory = if system == "aarch64-darwin" then
                "/Users/${user}"
              else
                "/home/${user}";
            }
          ];
        };
    in {
      nixosConfigurations = {
        ac-zenbook-2022 = mkNixOS "ac-zenbook-2022" "x86_64-linux";
        ac-gaming-pc = mkNixOS "ac-gaming-pc" "x86_64-linux";
      };

      homeConfigurations = {
        "${user}-x86_64-linux" = mkHome "" "x86_64-linux";
        "${user}-aarch64-linux" = mkHome "rpi5" "aarch64-linux";
      };
    };
}
