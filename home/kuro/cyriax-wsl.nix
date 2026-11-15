{ lib, ... }:

{
  imports = [
    ./shared
  ];

  programs.zsh.initContent = lib.mkAfter ''
    if [[ -n "$WT_SESSION" && -z "$TMUX" ]]; then
      tmux new-session -A -s main
    fi
  '';

  home.stateVersion = "26.05";
}
