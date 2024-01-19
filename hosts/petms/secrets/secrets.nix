let
  trustedKeys = import ../../../ssh-keys.nix "petms";
in
{
  "duckdns.age".publicKeys = trustedKeys;
  "cloudflared/24eb600a-ff9a-419d-bf8f-fc06df91207f.json.age".publicKeys = trustedKeys;
}
