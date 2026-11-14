{ pkgs, ... }:

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
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  };

  home.sessionPath = [
    "$HOME/Scripts"
    "$HOME/.cargo/bin"
    "$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin"
  ];

  home.stateVersion = "25.11";
}
