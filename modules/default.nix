{ config, lib, pkgs, nixpkgs, ... }:

{

  imports = [
    ./common
    ./users
    ./desktop
    ./fs
    ./secureboot
    ./network
    ./cloudflared
    ./ddns
    ./hypervisor
  ];

}
