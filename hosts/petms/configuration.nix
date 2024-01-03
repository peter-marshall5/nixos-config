# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./vms.nix
    ];

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.petms = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = import ../../ssh-keys.nix "petms";
    shell = pkgs.nushell;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    aria2
    git
    helix
  ];

  # List services that you want to enable:

  age.secrets.duckdns = {
    file = ./secrets/duckdns.age;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}

