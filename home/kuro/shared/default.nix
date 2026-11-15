{ pkgs, ... }:

{
  imports = [
    ./cli.nix
    ./emacs
    ./shell.nix
    ./tmux.nix
  ];

  home.username = "kuro";
  home.homeDirectory = "/home/kuro";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "e";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
