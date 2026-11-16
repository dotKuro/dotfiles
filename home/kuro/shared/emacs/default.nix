{
  config,
  pkgs,
  ...
}:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
    extraPackages =
      epkgs: with epkgs; [
        consult
        corfu
        embark
        embark-consult
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
            tree-sitter-rust
            tree-sitter-yaml
          ]
        ))
        vertico
      ];
  };

  services.emacs.enable = true;
  systemd.user.services.emacs.Service.Environment = "COLORTERM=truecolor";

  home.packages = with pkgs; [
    gopls
    marksman
    vscode-langservers-extracted
    yaml-language-server
    (writeShellScriptBin "e" ''
      exec ${config.programs.emacs.finalPackage}/bin/emacsclient -t "$@"
    '')
    (writeShellScriptBin "er" ''
      exec systemctl --user restart emacs
    '')
  ];

  xdg.configFile."emacs/init.el" = {
    source = ./init.el;
    onChange = ''
      (
        export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        if [ -S "$XDG_RUNTIME_DIR/emacs/server" ]; then
          ${pkgs.coreutils}/bin/timeout 10 ${config.programs.emacs.finalPackage}/bin/emacsclient --eval '(load-file user-init-file)' > /dev/null \
            || echo "emacs: reloading the config failed, restart with er"
        fi
      )
    '';
  };
}
