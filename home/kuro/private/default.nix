{
  inputs,
  osConfig,
  pkgs,
  ...
}:

{
  imports = [
    ./emacs
  ];

  programs = {
    zsh.envExtra = ''
      export GH_TOKEN="$(cat ${osConfig.age.secrets.github-token.path})"
    '';
    gcc.enable = true;
    gh.enable = true;
  };

  home.packages = with pkgs; [
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default
    claude-code
    google-cloud-sdk
    llvmPackages.llvm
    llvmPackages.libclang
    lld
    mitmproxy
    nmap
    nodejs
    rustup
    supabase-cli
    trunk
  ];

  home.sessionVariables = {
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
