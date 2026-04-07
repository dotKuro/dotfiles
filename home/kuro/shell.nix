{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    shellAliases = {
      ec = "$EDITOR ~/Dotfiles/home/kuro";
      esc = "$EDITOR ~/Dotfiles/hosts/cyriax";
      mc = "sudo nixos-rebuild switch --flake $HOME/Dotfiles";
    };
    
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-completions"; }
      ];
    };

    initContent = ''
      PROMPT="%F{cyan}%*%f %B%F{blue}%~%f%b > "

      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "''${key[Up]}" up-line-or-beginning-search
      bindkey "''${key[Down]}" down-line-or-beginning-search
    '';
  };

}
