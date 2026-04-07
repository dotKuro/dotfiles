{
  description = "dotKuro's dotfiles";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    wallpapers = {
      url = "git+file:///home/kuro/Pictures/Wallpapers";
      flake = false;
    };
    
  };
  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    lib = nixpkgs.lib;
  in
  {
    nixosConfigurations = {
      cyriax = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./hosts/cyriax
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            home-manager.users.kuro = import ./home/kuro;
          }
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
  };
}
