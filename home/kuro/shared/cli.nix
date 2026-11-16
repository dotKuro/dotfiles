{ pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      settings.user = {
        name = "Alexander Kampf";
        useConfigOnly = true;
      };
    };
    go.enable = true;
    jq.enable = true;
    htop.enable = true;
  };

  home.packages = with pkgs; [
    gnumake
    ripgrep
    unzip
    zip
  ];
}
