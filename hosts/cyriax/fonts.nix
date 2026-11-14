{ pkgs, ... }:

{
  # Only fonts that are explicitly referenced (waybar). Everything else falls
  # back to the NixOS default fonts (DejaVu, Liberation, ...).
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.hack
  ];
}
