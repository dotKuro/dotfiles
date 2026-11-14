{ pkgs, ... }:

{
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
  users.defaultUserShell = pkgs.zsh;
}
