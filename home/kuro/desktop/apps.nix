{ pkgs, ... }:

{
  programs = {
    kitty.enable = true;
    rofi.enable = true;
    vscode.enable = true;
  };

  services = {
    tailscale-systray.enable = true;
  };

  home.packages = with pkgs; [
    ausweisapp
    discord
    feh
    firefox
    gparted
    guvcview
    jadx
    prismlauncher
    rpi-imager
    slack
    spotify
    sway-contrib.grimshot
    telegram-desktop
    usbutils
  ];
}
