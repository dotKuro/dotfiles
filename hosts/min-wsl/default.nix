{
  imports = [
    ../shared/global

    ../shared/optional/wsl.nix

    ../shared/users/kuro
  ];

  networking.hostName = "min-wsl";

  system.stateVersion = "26.11";
}
