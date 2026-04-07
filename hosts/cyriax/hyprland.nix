{ inputs, pkgs, ... }:

let
  sddm-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "black_hole";
    themeConfig = {
      Background = "${inputs.wallpapers}/Quasar.png";
    };
  };
in

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  security.pam.services.hyprlock = {};

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
    ];
  };
  
  environment.systemPackages = with pkgs; [
    kitty
    sddm-theme
    kdePackages.qtmultimedia
  ];
}
