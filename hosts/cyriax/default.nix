{ pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix

      ./audio.nix
      ./boot.nix
      ./docker.nix
      ./fonts.nix
      ./hyprland.nix
      ./nixld.nix
      ./services.nix
      ./users.nix
      ./zsh.nix
    ];

  networking.hostName = "cyriax";
  time.timeZone = "Europe/Berlin";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;

  services.logind.settings.Login = {
    IdleAction = "suspend";
    IdleActionSec = "10min";
  };

  users.users.kuro.extraGroups = ["adbusers"];

  environment.systemPackages = with pkgs; [
    android-tools
    vim
  ];

  networking.firewall.enable = false;
}

