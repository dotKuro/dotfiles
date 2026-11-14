let
  kuro-cyriax = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAuR97CeIAevoHNy4SawMlA+vT9pZyGyfOyNxm8ZONo5";
  kuro-cyriax-wsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIALzmdS4IM7yjT8clB60B4qq5/4Y6BTwIicrVxRIoWoH";

  kuro = [
    kuro-cyriax
    kuro-cyriax-wsl
  ];
in
{
  "claude-token.age".publicKeys = kuro;
}
