let
  trustedKeys = import ../../../ssh-keys.nix "petms";
in
{
  "cloudflare.age".publicKeys = trustedKeys;
}
