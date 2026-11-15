{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
    extraPackages =
      epkgs: with epkgs; [
        corfu
        embark
        evil
        evil-collection
        magit
        marginalia
        markdown-mode
        orderless
        (treesit-grammars.with-grammars (
          grammars: with grammars; [
            tree-sitter-go
            tree-sitter-gomod
            tree-sitter-json
            tree-sitter-yaml
          ]
        ))
        vertico
      ];
  };

  services.emacs.enable = true;

  systemd.user.services.emacs.Unit = {
    X-RestartIfChanged = lib.mkForce true;
    X-Restart-Triggers = [ "${config.xdg.configFile."emacs/init.el".source}" ];
  };

  home.packages = with pkgs; [
    gopls
    marksman
    vscode-langservers-extracted
    yaml-language-server
    (writeShellScriptBin "e" ''
      exec ${config.programs.emacs.finalPackage}/bin/emacsclient -t "$@"
    '')
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;
}
