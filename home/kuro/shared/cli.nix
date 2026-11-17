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
    htop = {
      enable = true;
      settings = {
        show_program_path = 0;
        highlight_base_name = 1;
        shadow_distribution_path_prefix = 1;
        show_merged_command = 1;
      };
    };
  };

  home.packages = with pkgs; [
    gnumake
    ripgrep
    unzip
    zip
  ];
}
