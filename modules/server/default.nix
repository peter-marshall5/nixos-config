{ config, lib, pkgs, modulesPath, ... }:
{

  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")
    ./bridge-network.nix
    ./cloudflared.nix
    ./ddns.nix
    ./vms.nix
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Allow setting the root password manually
  users.mutableUsers = lib.mkForce true;

}
