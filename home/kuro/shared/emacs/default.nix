{
  config,
  lib,
  pkgs,
  ...
}:

let
  keys = import ../tiling-keys.nix;
  sprite = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/559.png";
    hash = "sha256-RxlyG7qHi84dx9y7mKkt9fUCgT7nnIZnn2XXbPTfxcc=";
  };
  reload = ''
    (
      export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      if [ -S "$XDG_RUNTIME_DIR/emacs/server" ]; then
        ${pkgs.coreutils}/bin/timeout 10 ${config.programs.emacs.finalPackage}/bin/emacsclient --eval '(load-file user-init-file)' > /dev/null \
          || echo "emacs: reloading the config failed, restart with er"
      fi
    )
  '';
in
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
    extraPackages =
      epkgs: with epkgs; [
        apheleia
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
            tree-sitter-rego
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
    regal
    vscode-langservers-extracted
    yaml-language-server
    (writeShellScriptBin "e" ''
      exec ${config.programs.emacs.finalPackage}/bin/emacsclient -t "$@"
    '')
    (writeShellScriptBin "er" ''
      exec systemctl --user restart emacs
    '')
    (writeShellScriptBin "goimports" ''
      exec ${gotools}/bin/goimports "$@"
    '')
  ];

  xdg.configFile."emacs/init.el" = {
    source = ./init.el;
    onChange = reload;
  };

  xdg.configFile."emacs/config" = {
    source = ./config;
    onChange = reload;
  };

  xdg.configFile."emacs/tiling-keys.el" = {
    text = ''
      ;;; -*- lexical-binding: t; -*-
      (defconst kuro/tiling-keys '(${
        lib.concatStringsSep " " (lib.mapAttrsToList (name: key: ''(${name} . "${key}")'') keys)
      }))
    '';
    onChange = reload;
  };

  xdg.configFile."emacs/start-art.el" = {
    source = pkgs.runCommand "start-art.el" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
      magick ${sprite} -trim +repage -depth 8 txt:- | awk -f ${./start-art.awk} > $out
    '';
    onChange = reload;
  };
}
