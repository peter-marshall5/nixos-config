let
  trustedKeys = import ../../../ssh-keys.nix "petms";
in
{
  "duckdns.age".publicKeys = trustedKeys;
  "cloudflared/ada56c81-89c9-403b-8d18-c20c39ab973c.json.age".publicKeys = trustedKeys;
}
