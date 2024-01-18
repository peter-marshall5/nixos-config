{ config, lib, pkgs, nixpkgs, ... }:

{

  imports = [
    ./common
    ./desktop
    ./fs
    ./secureboot
    ./network
    ./cloudflared
    ./ddns
    ./hypervisor
  ];

}
