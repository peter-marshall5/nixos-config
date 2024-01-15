{ config, lib, pkgs, ... }:

{

  imports = [
    ./common
    ./desktop
    ./fs
    ./secureboot
    ./network
    ./sshd
    ./cloudflared
    ./ddns
    ./vms
  ];

}
