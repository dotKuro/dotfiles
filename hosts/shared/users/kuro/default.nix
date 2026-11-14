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

  age.secrets.claude-token = {
    file = ../../../../secrets/claude-token.age;
    owner = "kuro";
  };

  age.secrets.github-token = {
    file = ../../../../secrets/github-token.age;
    owner = "kuro";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };

    users.kuro = import ../../../../home/kuro/${config.networking.hostName}.nix;
  };
}
