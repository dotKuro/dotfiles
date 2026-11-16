{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.identityPaths = [ "/home/kuro/.ssh/id_ed25519" ];

  age.secrets.github-token = {
    file = ../../../secrets/github-token.age;
    owner = "kuro";
  };
}
