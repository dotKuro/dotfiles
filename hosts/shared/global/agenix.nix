{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.identityPaths = [ "/home/kuro/.ssh/id_ed25519" ];
}
