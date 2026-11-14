{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix

    ../shared/global

    ../shared/optional/android.nix
    ../shared/optional/audio.nix
    ../shared/optional/docker.nix
    ../shared/optional/fonts.nix
    ../shared/optional/hyprland.nix
    ../shared/optional/tailscale.nix

    ../shared/users/kuro
  ];

  networking.hostName = "cyriax";

  virtualisation.docker.storageDriver = "btrfs";

  system.stateVersion = "25.11";
}
