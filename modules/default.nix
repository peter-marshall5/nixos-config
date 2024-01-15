{ config, lib, pkgs, ... }:

{

  imports = [
    ./common
    ./desktop
    ./fs
    ./secureboot
    ./network
    ./cloudflared
    ./ddns
    ./vms
  ];

}
