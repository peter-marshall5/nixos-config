{ config, lib, pkgs, modulesPath, ... }:
{

  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")
    ./network.nix
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

}
