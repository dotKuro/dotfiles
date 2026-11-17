{ config, ... }:

{
  programs.emacs.extraPackages = epkgs: [
    (epkgs.treesit-grammars.with-grammars (grammars: [ grammars.tree-sitter-rust ]))
  ];

  xdg.configFile."emacs/optional/rust.el" = {
    source = ./rust.el;
    onChange = config.xdg.configFile."emacs/init.el".onChange;
  };
}
