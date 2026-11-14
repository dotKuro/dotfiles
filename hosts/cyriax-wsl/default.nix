{ inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default

    ../shared/global

    ../shared/optional/docker.nix

    ../shared/users/kuro
  ];

  wsl = {
    enable = true;
    defaultUser = "kuro";
  };

  networking.hostName = "cyriax-wsl";

  system.stateVersion = "26.05";
}
