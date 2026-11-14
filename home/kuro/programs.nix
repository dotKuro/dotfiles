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
    ausweisapp
    claude-code
    discord
    feh
    firefox
    google-cloud-sdk
    gnumake
    gparted
    guvcview
    jadx
    jdk
    llvmPackages.llvm
    llvmPackages.libclang
    lld
    mitmproxy
    nmap
    nodejs
    prismlauncher
    rpi-imager
    rustup
    slack
    spotify
    supabase-cli
    sway-contrib.grimshot
    telegram-desktop
    trunk
    unzip
    usbutils
    zip
  ];
}
