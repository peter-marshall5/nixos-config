{ config, lib, pkgs, ... }: {

  ab.autoUpgrade = false;
  ab.ssh.enable = true;

}
