let
  petms = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPXpb3zcyWT+SPsjlBqlvgVr8+Vndqq5TSOWHu4lDL8h";
  petms-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOviPnrK/SPf3RVqkS18zmMguNE96OuDsJvHuai919Rw";
in
{
  "duckdns.age".publicKeys = [ petms petms-host ];
}
