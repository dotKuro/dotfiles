{
  description = "dotKuro's dotfiles";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpapers = {
      url = "git+file:///home/kuro/Pictures/Wallpapers";
      flake = false;
    };

  };
  outputs =
    inputs@{ nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree.override {
        settings.global.excludes = [ "hosts/*/hardware-configuration.nix" ];
      };

      nixosConfigurations = {
        cyriax = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/cyriax ];
          specialArgs = {
            inherit inputs;
          };
        };

        cyriax-wsl = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/cyriax-wsl ];
          specialArgs = {
            inherit inputs;
          };
        };

        min-wsl = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/min-wsl ];
          specialArgs = {
            inherit inputs;
          };
        };

        work-wsl = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/work-wsl ];
          specialArgs = {
            inherit inputs;
          };
        };
      };
    };
}
