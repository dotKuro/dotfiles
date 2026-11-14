{ pkgs, ... }:

{
  imports = [
    ./shared

    ./chrome.nix
    ./lock.nix
    ./programs.nix
    ./shell.nix
    ./theme.nix
    ./wm.nix
  ];

  home.sessionVariables = {
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.stateVersion = "25.11";
}
