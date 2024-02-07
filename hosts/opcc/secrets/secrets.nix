let
  trustedKeys = import ../../../ssh-keys.nix "opcc";
in
{
  "cloudflare.age".publicKeys = trustedKeys;
  "duckdns.age".publicKeys = trustedKeys;
}
