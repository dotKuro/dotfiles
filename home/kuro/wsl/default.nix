{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -n "$WT_SESSION" && -z "$TMUX" ]]; then
      tmux new-session -A -s main
    fi
  '';
}
