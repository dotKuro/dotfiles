{
  inputs,
  osConfig,
  pkgs,
  ...
}:

{
  programs = {
    zsh.envExtra = ''
      export CLAUDE_CODE_OAUTH_TOKEN="$(cat ${osConfig.age.secrets.claude-token.path})"
      export GH_TOKEN="$(cat ${osConfig.age.secrets.github-token.path})"
    '';
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
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default
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
