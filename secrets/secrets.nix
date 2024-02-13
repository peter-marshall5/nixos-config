let
  trustedKeysFor = import ../lib/ssh-keys.nix;
in
{
  "duckdns.age".publicKeys = trustedKeysFor "opcc";
}
