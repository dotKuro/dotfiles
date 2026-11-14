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
        embark
        evil
        evil-collection
        magit
        orderless
        vertico
      ];
  };

  services.emacs.enable = true;

  systemd.user.services.emacs.Unit = {
    X-RestartIfChanged = lib.mkForce true;
    X-Restart-Triggers = [ "${config.xdg.configFile."emacs/init.el".source}" ];
  };

  home.packages = with pkgs; [
    (writeShellScriptBin "e" ''
      exec ${config.programs.emacs.finalPackage}/bin/emacsclient -t "$@"
    '')
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;
}
