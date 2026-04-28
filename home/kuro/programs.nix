{ pkgs, ... }:

{
  programs = {
    gcc.enable = true;
    git.enable = true;
    go.enable = true;
    kitty.enable = true;
    rofi.enable = true;
    jq.enable = true;
    htop.enable = true;
    poetry.enable = true;
    vscode.enable = true;
    gh.enable = true;
  };
  
  services = {
    tailscale-systray.enable = true;
  };

  home.packages = with pkgs; [
    cargo
    claude-code
    discord
    gparted
    nmap
    nodejs
    prismlauncher
    rpi-imager
    slack
    spotify
    supabase-cli
    sway-contrib.grimshot
    telegram-desktop
  ];
}
