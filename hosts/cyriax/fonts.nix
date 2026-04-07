{ pkgs, lib, ... }:

{
  fonts.packages = with pkgs; [ font-awesome ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
