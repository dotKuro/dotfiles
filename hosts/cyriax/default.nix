{ pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix

      ./audio.nix
      ./boot.nix
      ./fonts.nix
      ./hyprland.nix
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

  environment.systemPackages = with pkgs; [
    vim
  ];
}

