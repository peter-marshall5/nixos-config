host:
let
  globalTrustedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPXpb3zcyWT+SPsjlBqlvgVr8+Vndqq5TSOWHu4lDL8h petms@peter-pc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAtjD6VShP3fXpM6Slv458S4Uuhvd/14gnK7oWoRSjK petms@peter-chromebook"
  ];
  hostKeys = {
    petms = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOviPnrK/SPf3RVqkS18zmMguNE96OuDsJvHuai919Rw petms@petms";
  };
in
globalTrustedKeys ++ [hostKeys."${host}"]
