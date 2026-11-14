{ pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./nix-ld.nix
    ./zsh.nix
  ];

  time.timeZone = "Europe/Berlin";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
  ];
}
