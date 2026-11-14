{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./android.nix
    ./audio.nix
    ./boot.nix
    ./docker.nix
    ./fonts.nix
    ./hyprland.nix
    ./networking.nix
    ./nixld.nix
    ./power.nix
    ./users.nix
    ./zsh.nix
  ];

  networking.hostName = "cyriax";
  time.timeZone = "Europe/Berlin";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [ pkgs.vim ];

  system.stateVersion = "25.11";
}
