{ config, lib, pkgs, ... }:
{

  imports = [
    ./network.nix
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

}
