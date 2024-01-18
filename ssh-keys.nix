host:
let
  globalTrustedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKr28cS1Xg/XHxpAO7NkFstbMiqMPo+fz+QjJHkGn+2S petms@peter-pc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAtjD6VShP3fXpM6Slv458S4Uuhvd/14gnK7oWoRSjK petms@peter-chromebook"
  ];
  hostKeys = {
    petms = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILna+ZgXyTHYM4OHgyPkoaNom83IsTJayfXTeUdi99o5 petms@petms";
  };
in
globalTrustedKeys ++ (if host != "" then [hostKeys."${host}"] else [])
