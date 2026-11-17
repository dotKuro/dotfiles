{
  imports = [
    ../shared/global

    ../shared/optional/docker.nix
    ../shared/optional/secrets.nix
    ../shared/optional/wsl.nix

    ../shared/users/kuro
  ];

  networking.hostName = "work-wsl";

  home-manager.users.kuro = import ../../home/kuro/work-wsl.nix;

  system.stateVersion = "26.11";
}
