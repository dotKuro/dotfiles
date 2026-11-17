{
  imports = [
    ../shared/global

    ../shared/optional/docker.nix
    ../shared/optional/wsl.nix

    ../shared/users/kuro
  ];

  networking.hostName = "min-wsl";

  home-manager.users.kuro = import ../../home/kuro/min-wsl.nix;

  system.stateVersion = "26.11";
}
