{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };
  users.users.kuro.extraGroups = [ "docker" ];
}
