{
  description = "Universal Config for ac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    catppuccin.url = "github:catppuccin/nix";
    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    weave.url = "github:Ataraxy-Labs/weave";
  };

  outputs = { self, nixpkgs, home-manager, stylix, catppuccin, walker
    , nix-index-database, weave, ... }@inputs:
    let
      user = "ac";

      mkNixOS = host: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs user; };
          modules = [
            ./hosts/${host}/default.nix

            stylix.nixosModules.stylix
            catppuccin.nixosModules.catppuccin
            nix-index-database.nixosModules.nix-index

            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user; };
              home-manager.backupFileExtension = "backup";

              home-manager.sharedModules = [
                stylix.homeModules.stylix
                catppuccin.homeModules.catppuccin
                inputs.dms.homeModules.dank-material-shell
                ./modules/system/theme.nix
                ./modules/system/kitty.nix
                walker.homeManagerModules.default
                ./modules/desktop/launcher/walker.nix
                nix-index-database.homeModules.nix-index
              ];

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
            catppuccin.homeModules.catppuccin
            nix-index-database.homeModules.nix-index
            ./modules/system/theme.nix

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
        ac-zenbook-2025 = mkNixOS "ac-zenbook-2025" "x86_64-linux";
        ac-main-pc = mkNixOS "ac-main-pc" "x86_64-linux";
      };

      homeConfigurations = {
        "${user}-x86_64-linux" = mkHome "" "x86_64-linux";
        "${user}-aarch64-linux" = mkHome "rpi5" "aarch64-linux";
      };
    };
}
