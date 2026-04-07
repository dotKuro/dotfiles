{ config, pkgs, ... }:

{
  home.username = "kuro";
  home.homeDirectory = "/home/kuro";
  
  imports = [
    ./chrome.nix
    ./lock.nix
    ./programs.nix
    ./shell.nix
    ./theme.nix
    ./wm.nix
  ];

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.sessionPath = [
    "$HOME/Scripts"
  ];

  home.stateVersion = "25.11";
}
