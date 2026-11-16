{
  imports = [
    ../shared/global

    ../shared/optional/docker.nix
    ../shared/optional/wsl.nix

    ../shared/users/kuro
  ];

  networking.hostName = "min-wsl";

  system.stateVersion = "26.11";
}
