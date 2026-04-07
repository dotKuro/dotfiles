{ ... }:

{
  users.users.kuro = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    uid = 1337;
    initialPassword = "1337";
  };
}
