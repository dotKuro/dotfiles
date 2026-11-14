{ pkgs, ... }:

{
  programs = {
    gcc.enable = true;
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
    gh.enable = true;
  };

  home.packages = with pkgs; [
    claude-code
    google-cloud-sdk
    gnumake
    llvmPackages.llvm
    llvmPackages.libclang
    lld
    mitmproxy
    nmap
    nodejs
    ripgrep
    rustup
    supabase-cli
    trunk
    unzip
    zip
  ];
}
