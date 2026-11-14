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
  # Hyprland 0.56.1 requires glaze 7.2.0, but nixpkgs moved glaze to 8.0.0,
  # which its CMake rejects (falls back to a sandboxed-forbidden FetchContent).
  # Drop this overlay once nixpkgs ships a Hyprland compatible with glaze 8.
  nixpkgs.overlays = [
    (final: prev: {
      hyprland = prev.hyprland.override {
        glaze = prev.glaze.overrideAttrs (old: {
          version = "7.2.0";
          src = final.fetchFromGitHub {
            owner = "stephenberry";
            repo = "glaze";
            tag = "v7.2.0";
            hash = "sha256-f3NVRi3SXKo42hn0WCw7JsOK3EkdOVJIcuzhPorKjFY=";
          };
        });
      };
    })
  ];

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
