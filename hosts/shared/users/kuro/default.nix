{ config, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  users.users.kuro = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    uid = 1337;
    initialPassword = "1337";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };

    users.kuro = import ../../../../home/kuro/${config.networking.hostName}.nix;
  };
}
