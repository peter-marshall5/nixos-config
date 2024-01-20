let
  trustedKeys = import ../../../ssh-keys.nix "opcc";
in
{
  "duckdns.age".publicKeys = trustedKeys;
  "cloudflared/c7f932c2-213b-4cca-9e6e-87052a5a849a.json.age".publicKeys = trustedKeys;
}
