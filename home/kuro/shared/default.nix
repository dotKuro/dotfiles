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
  };
}
