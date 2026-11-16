{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    shellAliases = {
      ec = "$EDITOR ~/Dotfiles/home/kuro";
      esc = "$EDITOR ~/Dotfiles/hosts";
      mc = "sudo nixos-rebuild switch --flake $HOME/Dotfiles";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-completions"; }
      ];
    };

    initContent = ''
      # Git branch info via vcs_info
      autoload -Uz vcs_info
      zstyle ':vcs_info:*' enable git
      zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'
      zstyle ':vcs_info:git:*' actionformats ' %F{magenta}(%b|%a)%f'
      precmd_functions+=(vcs_info)
      setopt prompt_subst

      # Last exit code, shown in red only when non-zero
      PROMPT='%F{cyan}%*%f %B%F{blue}%~%f%b''${vcs_info_msg_0_} %(?..%F{red}[%?]%f )> '

      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "''${key[Up]}" up-line-or-beginning-search
      bindkey "''${key[Down]}" down-line-or-beginning-search
    '';
  };

}
