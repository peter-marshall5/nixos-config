let
  hostKeys = import ../ssh/host-keys.nix;
  trustedKeys = import ../ssh/trusted-keys.nix;
  keysFor = hosts: (map (host: hostKeys.${host}) hosts) ++ trustedKeys;
in
{
  "duckdns.age".publicKeys = keysFor ["opcc"];
}
