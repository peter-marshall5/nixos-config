{ config, lib, pkgs, modulesPath, ... }:
{

  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")
    ./bridge-network.nix
    ./cloudflared.nix
    ./ddns.nix
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

}