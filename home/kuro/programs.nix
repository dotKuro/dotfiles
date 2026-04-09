{ pkgs, ... }:

{
  programs = {
    git.enable = true;
    kitty.enable = true;
    rofi.enable = true;
    jq.enable = true;
    htop.enable = true;
    vscode.enable = true;
    gh.enable = true;
  };
  
  services = {
    tailscale-systray.enable = true;
  };

  home.packages = with pkgs; [
    claude-code
    discord
    prismlauncher
    slack
    sway-contrib.grimshot
    telegram-desktop
  ];
}
