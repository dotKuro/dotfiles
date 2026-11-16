{
  imports = [
    ../shared/global

    ../shared/optional/docker.nix
    ../shared/optional/secrets.nix
    ../shared/optional/wsl.nix

    ../shared/users/kuro
  ];

  networking.hostName = "cyriax-wsl";

  system.stateVersion = "26.05";
}
