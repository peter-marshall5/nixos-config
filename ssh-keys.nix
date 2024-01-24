host:
let
  globalTrustedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKr28cS1Xg/XHxpAO7NkFstbMiqMPo+fz+QjJHkGn+2S petms@peter-pc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmDLXO+D5yZGkhn+qN6HwM5zKDGFENyYiqPkjZMNWA9 petms@Peter-PC"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAtjD6VShP3fXpM6Slv458S4Uuhvd/14gnK7oWoRSjK petms@peter-chromebook"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILna+ZgXyTHYM4OHgyPkoaNom83IsTJayfXTeUdi99o5 petms@petms"
  ];
  hostKeys = {
    petms = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPa61hyCMApITn5idnqBmi9XhQs7a4zr10lwf7H8NiSL root@petms";
    opcc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGvKdiLNRg9sKA9espO0tvNV26WKIzzApdoUsKicxN6 root@opcc";
  };
in
globalTrustedKeys ++ (if host != "" then [hostKeys."${host}"] else [])
