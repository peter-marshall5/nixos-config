let
  trustedKeys = import ../../../ssh-keys.nix "petms";
in
{
  "duckdns.age".publicKeys = trustedKeys;
  "tunnel-petms.age".publicKeys = trustedKeys;
}
