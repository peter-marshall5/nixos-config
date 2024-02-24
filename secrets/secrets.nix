let
  hostKeys = import ../cfg/ssh/host-keys.nix;
  trustedKeys = import ../cfg/ssh/trusted-keys.nix;
  keysFor = hosts: (map (host: hostKeys.${host}) hosts) ++ trustedKeys;
in
{
  "duckdns.age".publicKeys = keysFor ["opcc"];
}
