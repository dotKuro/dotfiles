{ pkgs, ... }:

{
  imports = [
    ./cli.nix
    ./shell.nix
  ];

  home.username = "kuro";
  home.homeDirectory = "/home/kuro";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
