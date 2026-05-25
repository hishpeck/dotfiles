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
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    cosmic-ctl.url = "github:cosmic-utils/cosmic-ctl";
    cosmic-ctl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, stylix, catppuccin, walker
    , nix-index-database, noctalia, cosmic-ctl, ... }@inputs:
    let
      user = "ac";

      nixosHosts = [
        { name = "ac-zenbook-2022"; system = "x86_64-linux"; }
        { name = "ac-zenbook-2025"; system = "x86_64-linux"; }
        { name = "ac-main-pc";      system = "x86_64-linux"; }
      ];

      sharedHomeModules = [
        stylix.homeModules.stylix
        catppuccin.homeModules.catppuccin
        inputs.dms.homeModules.dank-material-shell
        ./modules/home/theme.nix
        ./modules/home/desktop/cosmic-config.nix
        ./modules/home/desktop/launcher/walker.nix
        walker.homeManagerModules.default
        noctalia.homeModules.default
        nix-index-database.homeModules.nix-index
      ];

      mkNixOS = host: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs user self; };
          modules = [
            ./hosts/${host}/default.nix

            stylix.nixosModules.stylix
            catppuccin.nixosModules.catppuccin
            nix-index-database.nixosModules.nix-index

            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user self; };
              home-manager.backupFileExtension = "backup";

              home-manager.sharedModules = sharedHomeModules;

              home-manager.users.${user} = import ./hosts/${host}/home.nix;
            }
          ];
        };

      mkHome = host: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs user self; };
          modules = [
            ./hosts/${host}/default.nix

            stylix.homeModules.stylix
            catppuccin.homeModules.catppuccin
            nix-index-database.homeModules.nix-index
            ./modules/home/theme.nix

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
      nixosConfigurations = builtins.listToAttrs (map (h: {
        name  = h.name;
        value = mkNixOS h.name h.system;
      }) nixosHosts);

      homeConfigurations = {
        "${user}-x86_64-linux" = mkHome "" "x86_64-linux";
        "${user}-aarch64-linux" = mkHome "rpi5" "aarch64-linux";
      };
    };
}
